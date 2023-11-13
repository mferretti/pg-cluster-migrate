#/bin/bash
OLD_VERSION=-1
NEW_VERSION=-1
CHECK="--check"

USAGE="migrate -o {old version number} -n {new version number} [-c {t/f default t}}]"
while getopts o:n:c flag
do
        case "${flag}" in
                o) OLD_VERSION=${OPTARG};;
                n) NEW_VERSION=${OPTARG};;
                c) CHECK=${OPTARG};;
        esac
done

if [ ${OLD_VERSION} -eq -1 ]
then
        echo $USAGE
        exit -1
fi

if [ ${NEW_VERSION} -eq -1 ]
then
        echo $USAGE
        exit -1
fi

if [ -z "${CHECK}" ]
then
        CHECK="--check"
elif [ "${CHECK}" = "t" ]
then
        CHECK="--check="
else
        CHECK=""
fi
BIN=/usr/lib/postgresql/${NEW_VERSION}/bin/pg_upgrade
OLD_DATA_DIR=/var/lib/postgresql/${OLD_VERSION}/main/
NEW_DATA_DIR=/var/lib/postgresql/${NEW_VERSION}/main/
OLD_BIN_DIR=/usr/lib/postgresql/${OLD_VERSION}/bin/
NEW_BIN_DIR=/usr/lib/postgresql/${NEW_VERSION}/bin/
OLD_CONFIG="/etc/postgresql/${OLD_VERSION}/main/postgresql.conf"
NEW_CONFIG="/etc/postgresql/${NEW_VERSION}/main/postgresql.conf"

echo " MIGRATION DATA:" 
echo " --- OLD (version ${OLD_VERSION})---"
echo "  bin directory : ${OLD_BIN_DIR} "
echo "  cluster data  : ${OLD_DATA_DIR}"
echo "  cluster config: ${OLD_CONFIG}"
echo " --- NEW (version ${NEW_VERSION})"
echo "  bin directory : ${NEW_BIN_DIR}"
echo "  cluster data  : ${NEW_DATA_DIR}"
echo "  cluster config: ${NEW_CONFIG}"

if [ -z "${CHECK}" ]
then
        echo " DRY RUN=YES"
fi

echo "Are you ok with these settings (y/N)?: "
read OK
if [ -z "${OK}" ]
then
        echo "quit"
elif [ "${OK}" = "y" ] || [ "${OK}" = "Y" ]
then
        ${BIN} --old-datadir=${OLD_DATA_DIR} --new-datadir=${NEW_DATA_DIR} --old-bindir=${OLD_BIN_DIR} --new-bindir=${NEW_BIN_DIR} --old-options '-c config_file=${OLD_CONFIG}' --new-options '-c config_file=${NEW_CONFIG} ${CHECK}'
else
        echo "quit"
fi
