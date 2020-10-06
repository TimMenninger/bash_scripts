#!/usr/bin/python3
import json
import shlex
from subprocess import Popen, PIPE
import re
import os
import sys

# TODO: look up clangd extension/package for vim

try:
    from subprocess import DEVNULL # py3k
except ImportError:
    import os
    DEVNULL = open(os.devnull, 'wb')

# read file
OriginalCommands = []
if os.path.isfile('compile_commands.json'):
    with open('compile_commands.json', 'r') as TheFile:
        original_data=TheFile.read()
        if len(original_data) > 0:
            OriginalCommands = json.loads(original_data)

# Reorganize Original commands so that it is indexed by filename
Index = {}

for Entry in OriginalCommands:
    try:
        Index[Entry["file"]] = Entry
    except:
        continue

def transformedArg(IsCPP, TheArg):
    if TheArg.startswith("-I"):
        return [TheArg]
    if TheArg.startswith("-D"):
        return [TheArg]
    if TheArg.startswith("-isystem"):
        return [TheArg]
    if TheArg == "-G" or TheArg == "-g":
        return ["-g"]
    if TheArg.startswith("--c++") and IsCPP:
        return ["-std=" + TheArg[2:]]
    if TheArg.startswith("--sys_include_directory="):
        return [
            "-isystem" + TheArg[len("--sys_include_directory="):],
        ]
    return []

def IsSource(File):
    file, ext = os.path.splitext(File)
    return ext == ".c" or ext == ".h" or ext == ".cpp" or ext == ".cc" or ext == ".hpp"

def GetCommands(path):
    gpj = os.path.basename(path)
    path = os.path.dirname(path)
    path = os.path.abspath(path)
    Result = []

    gcmd = [
        "gbuild",
        "-list",
    ]
    print(' '.join(gcmd))
    p = Popen(gcmd, cwd=path, stdout=PIPE, stderr=DEVNULL)
    AllFiles = p.communicate()[0].decode('utf-8').splitlines()
    AllFiles = [ x.strip() for x in AllFiles ]
    AllFiles = [ x for x in AllFiles if IsSource(x) ]
    batchsize = 500
    for i in range(0, len(AllFiles), batchsize):
        batch = AllFiles[i:i+batchsize] # the result might be shorter than batchsize at the end
        if i != 0:
        sys.stdout.write("\033[K")
        print("Batch: " + str(i) + "-" + str(i + batchsize) + " of " + str(len(AllFiles)))
        gcmd = ["gbuild"] + batch + [
            "-commands",
            "-info",
            "-noreasons",
            "-noprogress",
            "-nolink",
            "-ignore",
            "-ignore_parse_errors",
            "-fullexternals",
        ]
        p = Popen(gcmd, cwd=path, stdout=PIPE, stderr=DEVNULL)
        output = p.communicate()[0].decode('utf-8')
        Responses = output.replace("\\\n", "").splitlines()
        for Response in Responses:
            Response = shlex.split(Response)
            FileTypeIdx = None
            try:
                FileTypeIdx = Response.index("-filetype.c")
            except:
                try:
                    FileTypeIdx = Response.index("-filetype.cc")
                except:
                    continue
            if FileTypeIdx == None:
                continue

            command = os.path.basename(Response[0])
            file = Response[FileTypeIdx + 1]
            ext = os.path.splitext(file)[1]
            # Whitelist arguments
            IsCPP = ext == ".cc" or ext == ".cpp" or ext == ".hpp" or command == "gcx"
            transformedArgs = []
            transformedArgs.append("-D__CHAR_BIT=8")
            transformedArgs.append("-D__ghs")
            transformedArgs.append("-D__INT_BIT=32")
            transformedArgs.append("-D__LONG_BIT=64")
            transformedArgs.append("-D__SHRT_BIT=16")
            transformedArgs.append("-D__REG_BIT=64")
            transformedArgs.append("-D__LLONG_BIT=64")
            transformedArgs.append("-D__PTR_BIT=64")
            transformedArgs.append("-D__WCHAR_BIT=16")
            transformedArgs.append("-D__ghs_alignment=4")
            transformedArgs.append("-DCACHE_LINE_SIZE=256")
            transformedArgs.append("-D__MISRA_8")
            transformedArgs.append("-D_STCONS=")
            transformedArgs.append("_HAS_CPP11")
            transformedArgs.append("-D_NOINLINE")
            transformedArgs.append("-D__asm")
            transformedArgs.append("-D__DARWIN_ALIAS")
            transformedArgs.append("-D__DARWIN_ALIAS_STARTING")

            # transformedArgs.append("-nostdinc")
            # transformedArgs.append("-nostdinc++")
            # print(transformedArgs)
            transformedArgs.append("-isystem/Volumes/FS/tools/bin/linux64/green/ansi")
            transformedArgs.append("-I/Volumes/FS/tools/bin/linux64/green/ansi")
            if "-DTARGET_INTEGRITY" in Response:
                transformedArgs.append("-nostdinc")
                #transformedArgs.append("-nostdinc++")
                transformedArgs.append("-D__INTEGRITY__")
                transformedArgs.append("-D__INTEGRITY")
                # transformedArgs.append("-I/Volumes/FS/tools/bin/linux64/green/ecxx")
                #transformedArgs.append("-isystem/Volumes/FS/tools/bin/linux64/green/scxx")
                transformedArgs.append("-I" + os.path.abspath(os.path.normpath(os.path.join(os.path.dirname(__file__), "config/iot_os_dir/rtos/core-mz-d/INTEGRITY-include"))))
                transformedArgs.append("-I" + os.path.abspath(os.path.normpath(os.path.join(os.path.dirname(__file__), "config/iot_os_dir/rtos/modules/ghs/INTEGRITY-include-full"))))
            else:
                transformedArgs.append("-D__linux__")
                # transformedArgs.append("-I/Volumes/FS/tools/bin/linux64/green/include/linux86")

            for x in Response[1:]:
                for y in transformedArg(IsCPP, x):
                    transformedArgs.append(y)

            compiler = "clang"
            if IsCPP:
                compiler = "clang++"
            cmd = compiler + " " + " ".join(transformedArgs) + ' "' + file + '"'
            cmd = cmd.replace("/media/psf/FS/", "/Volumes/FS/")
            file = os.path.abspath(os.path.normpath(os.path.join(path, file)))
                # Get the absolute path of file for use in the file field.
                # the response has it relative to the given path dir so we join
            sanpath = path.replace("/media/psf/FS/", "/Volumes/FS/")
            file = file.replace("/media/psf/FS/", "/Volumes/FS/")
            entry = {
                "directory": sanpath,
                "command": cmd,
                "file": file
            }
            Index[file] = entry

GetCommands("endpoints/default.gpj")
GetCommands("mtk/default.gpj")

with open("compile_commands.json", "w") as TheFile:
    json.dump(list(Index.values()), TheFile)
