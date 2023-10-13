#!/bin/sh

# copy app settings from one env to another
BRAND=mg
ENV=qa47
ENV_NEW=qa21
OLD_DB=webqa2/dtc_app_owner
NEW_DB=webqa2/dtc_app_owner
MEAD="MEAD-42731"
TMP=/Users/818381/Desktop/workdir/$MEAD/tmp/settingcopy/mead-$MEAD.save

#cd /Users/818381/Desktop/WSI/svn/devops/packaging/wsgc-appsettings-configuration/trunk/appsetting-properties/schema-site/
cd /Users/818381/Desktop/WSI/svn/schema-site/
svn up
if [ -z "$OLD_DB" ]
then
	echo "Can't figure out old DB"
	exit 1
fi
OLD_DIR=$OLD_DB/$BRAND/override
NEW_DIR=$NEW_DB/$BRAND/override

PROPS=/Users/818381/Desktop/workdir/$MEAD/tmp/properties-$ENV-$BRAND
PROPS2=/Users/818381/Desktop/workdir/$MEAD/tmp/properties-$ENV_NEW-$BRAND
mkdir -p $TMP

[ -f $TMP/override.properties.$BRAND ] || cp $NEW_DIR/override.properties $TMP/override.properties.$BRAND

# seed the new file with the existing properties from the new schema
cat $NEW_DIR/override.properties > $PROPS
echo >> $PROPS

#sed -i -e "/.$ENV_NEW./d" $PROPS
sed -i -e "/.$ENV_NEW.a=/d" $PROPS
sed -i -e "/.$ENV_NEW.b=/d" $PROPS
sed -i -e "/.$ENV_NEW.r=/d" $PROPS
sed -i -e "/.$ENV_NEW.t=/d" $PROPS
sed -i -e "/.$ENV_NEW.s=/d" $PROPS
sed -i -e "/.$ENV_NEW.h=/d" $PROPS
sed -i -e "/.$ENV_NEW.p=/d" $PROPS
sed -i -e "/.$ENV_NEW.i=/d" $PROPS
sed -i -e "/.$ENV_NEW.m=/d" $PROPS
sed -i -e "/.$ENV_NEW.n=/d" $PROPS

#exit 1
# add the properties for $ENV NEW to the newly seeded file
cat $OLD_DIR/override.properties | egrep -i "\.$ENV\." | egrep -vi "^#" | sort -u >> $PROPS2
sed -i -e "s/.$ENV./.$ENV_NEW./g" $PROPS2

# copy the regression props to qa3
cat $PROPS2 >> $PROPS
#ls -l $PROPS
#diff $NEW_DIR/override.properties $PROPS

cp $PROPS $NEW_DIR/override.properties
#ls -l $NEW_DIR/override.properties

MSG="[$MEAD] copy $BRAND $ENV/$OLD_DB appsettings to $ENV_NEW/$NEW_DB "
echo $MSG
#svn commit $NEW_DIR/override.properties -m "[$MEAD] $MSG"
