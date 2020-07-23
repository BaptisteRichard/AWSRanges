#!/bin/bash

. $HOME/.bash_profile;

echo -e "print network_objects AWS_AMAZON_GLOBAL\n-q\n" | /opt/CPsuite-R77/fw1/bin/dbedit -local
echo -e "print network_objects AWS_AMAZON_eu-west-1\n-q\n" | /opt/CPsuite-R77/fw1/bin/dbedit -local
echo -e "print network_objects AWS_AMAZON_eu-west-2\n-q\n" | /opt/CPsuite-R77/fw1/bin/dbedit -local
echo -e "print network_objects AWS_AMAZON_eu-west-3\n-q\n" | /opt/CPsuite-R77/fw1/bin/dbedit -local

