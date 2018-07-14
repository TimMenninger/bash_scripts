export PATH="$PATH:$HOME/bin"

# Setting PATH for Python 3.5
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH

# added by Anaconda3 2.4.0 installer
export PATH="//anaconda/bin:$PATH"

# MacPorts Installer addition on 2016-01-17_at_23:23:52: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

alias zonedin='cd ~/Documents/Important/Projects/zonedin'
alias classes='cd ~/Documents/Important/School/Caltech/Classes'
alias projects='cd ~/Documents/Important/Projects'
alias work='cd ~/Documents/Important/Work'
alias hbar='cd ~/Documents/Important/Tutoring/Hbar'
alias resize='printf "\e[8;20;104t"'
alias fullscreen='printf "\e[8;57;211t";printf "\e[3;0;0t"'
alias put00='resize;printf "\e[3;0;0t"'
alias put01='resize;printf "\e[3;640;0t"'
alias put10='resize;printf "\e[3;0;290t"'
alias put11='resize;printf "\e[3;640;290t"'
alias atom='Atom'
alias bebi103='classes;cd BE\:Bi103/09-bebi103'
alias cs171='classes;cd CS171'
alias serenify='cd ~/Documents/Important/Work/Serenify/serenify-js'
alias jn='jupyter notebook'
alias wg103pw='wget --user bebi103 --password logicofscience'
alias ee119b='classes;cd EE119b'
alias drone='classes;cd CS081'
alias wrap='python ~/Documents/Important/Tools/wrap.py'
alias hbarjava='hbar;cd Java\ Programming'
alias scramble='python /usr/local/scramble/scramble.py'
alias werewolf='php ~/Documents/Important/Work/Second\ Spectrum/slackwolf/bot.php'
alias pyserv='python -m SimpleHTTPServer'
alias advcpp='classes;cd CS011/Adv\ C++'
alias db_serenify='echo"";echo "Note:    password is serenify";echo "";psql --host=serenify-dev.cqloulntagp0.us-west-2.rds.amazonaws.com --port=5432 --username=serenify --password'
alias ccheck='c_style_check'
alias cs24='desktop;cd cs24/cs24-autograde/sets/'
alias pacman='classes;cd CS011/Adv\ C++/pacman/'
alias serenify_search='serenify;grep -lr --exclude-dir=./node_modules --exclude-dir=./logs'
alias aws_ec2='ssh -i /Users/tmenninger/Documents/Important/Work/Serenify/serenify-js/sandbox/serenify-v1.pem ubuntu@ec2-54-191-97-201.us-west-2.compute.amazonaws.com'
alias clockproj='cd ~/Documents/Important/Projects/clock'
