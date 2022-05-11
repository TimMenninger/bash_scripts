import subprocess
import typing

class _ShellResult:
    def __init__(self, returncode, stdout: typing.List[bytes], stderr: typing.List[bytes], success_codes: typing.List[int]=[0]):
        self.returncode = returncode
        self.success_codes = success_codes[:] # deep copy
        self.stdout = stdout if stdout is not None else []
        self.stderr = stderr if stderr is not None else []
        for i, line in enumerate(self.stdout):
            self.stdout[i] = line.decode('utf-8') if type(line) is bytes else line
        for i, line in enumerate(self.stderr):
            self.stderr[i] = line.decode('utf-8') if type(line) is bytes else line

    # operators

    def __bool__(self):
        return self.returncode in self.success_codes

    def __int__(self):
        return self.returncode

    def __str__(self):
        return '\n'.join(self.stdout)

    # builder

    def grep(self, terms):
        if type(terms) is str:
            terms = [ terms ]
        matches = [ line for line in self.stdout if all([ term in line for term in terms ]) ]
        return _ShellResult(0 if len(matches) > 0 else 1, matches, [])

    # convenience

    def oneline(self) -> str:
        return self.stdout[0].strip() if len(self.stdout) > 0 else None

class ShellHelper:
    def __init__(self):
        self.history = []

    def run(self, cmd, stdin_string=None, stdin_file=None, success_codes=[0]) -> _ShellResult:
        p = subprocess.Popen(cmd,
                             shell=True,
                             stdin=(stdin_file if stdin_file else
                                    subprocess.PIPE if stdin_string else
                                    None),
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE,
                             executable='/bin/bash')
        stdout, stderr = p.communicate(input=stdin_string.encode() if stdin_string else None)

        stdout = stdout.decode()
        stderr = stderr.decode()

        self.history.append((cmd, _ShellResult(p.returncode, stdout.split('\n'), stderr.split('\n'), success_codes=success_codes)))
        return self.last_result()

    def last_result(self):
        return self.history[-1][1] if len(self.history) > 0 else None
