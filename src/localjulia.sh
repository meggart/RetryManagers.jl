basedir=$1
jlname=$2
all=( ${@} )
rest="${all[*]:2}"
userbase=/scratch/$USER/clusterjulia
mkdir -p $userbase
rsync -l -r $basedir/$jlname $userbase/
$userbase/$jlname/bin/julia $rest