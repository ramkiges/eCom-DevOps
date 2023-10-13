#!/bin/sh 

#key=frontend.tableOwner
MEAD='MEAD-19703'
BRAND=mg
ENV=qa43
#cd /Users/sganesh1/svn_repos/frontend-2.1/qa/config/app/trunk
Cd /Users/818381/Desktop/SVN/application/frontend-2.1/frontend-2.1/qa/config/app/trunk
SRC_POM=$BRAND/uat2/pom.xml
DEST_POM=$BRAND/qa43/pom.xml
svn up
TMP=/Users/818381/workdir/$MEAD
mkdir -p $TMP
echo "back up the pom in $BRAND $ENV"
cp $DEST_POM $TMP/$BRAND-$ENV.pom.save

for prop in \
frontend.tableOwner \
datasource.session.url \
datasource.session.username \
datasource.session.password \
datasource.ecomDB.url \
datasource.ecomDB.username \
datasource.ecomDB.password  \
frontend.jms.providerUrl \
frontend.jms.username \
frontend.jms.password \
frontend.jms.subscriberClientId \
frontend.jmsWismo.providerUrl \
frontend.jmsWismo.username \
frontend.jmsWismo.password \
frontend.jmsWismo.usernameCov2 \
frontend.jmsWismo.passwordCov2 \
frontend.jmsOrder.providerUrl \
frontend.jmsOrder.username \
frontend.jmsOrder.password \
frontend.jmsOrderCreate.providerUrl \
frontend.jmsOrderCreate.username \
frontend.jmsOrderCreate.password \
frontend.jmsOrderPricing.providerUrl \
frontend.jmsOrderPricing.username \
frontend.jmsOrderPricing.password \
frontend.jmsOrderReservation.providerUrl \
frontend.jmsOrderReservation.username \
frontend.jmsOrderReservation.password \
frontend.loyaltyJms.url \
frontend.loyaltyJms.queueName \
frontend.loyaltyJms.username \
frontend.loyaltyJms.password
do
        s_key=$(grep -iw "$prop>" $SRC_POM | awk -F '[<>]' '{ print $0 }')
        d_key=$(grep -iw "$prop>" $DEST_POM | awk -F '[<>]' '{ print $0 }')
        if [ -n "$s_key" ] && [ -n "$d_key" ]
        then
                #echo "Source $s_key"
                #echo "Dest $d_key"
                echo "copying $prop value from $SRC_POM to $DEST_POM" 
                sed -i -e "s|$d_key|$s_key|g" "$DEST_POM"   
        else
                echo "property '$prop' not found"
        fi
done


MSG="[$MEAD] copy pom props from $SRC_POM to $DEST_POM"
echo $MSG
#svn commit $DEST_POM -m "[MEAD-14358] $MSG"
