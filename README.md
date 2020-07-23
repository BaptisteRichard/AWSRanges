# AWSRanges
Scripts for auto-updating Checkpoint R77.30 policy to match AWS public ranges

# Pre-requisites and naming syntax
These scripts were written in my working environment, so naming conventions are hard coded. It should not be too hard to adapt to yours, but here it goes :
## Objects on Checkpoint's Smartcenter
Several groups are created (and should exist, even empty, before first launch) following this syntax :
AWS_<service>_<region>
For example, a group called AWS_AMAZON_eu-west-1 will contain all ranges for the service AMAZON and region eu-west-1

## Smartcenter configuration
You will need to create a cronuser on smartcenter (for launching cronjobs more than once a day). I'm not going to explain this, there is plenty of docs on the internet

I use cron job to fetch the relevant parts of object database and send them to the server running the diff scripts. I guess all could be done on smartcenter to get rid of the scp bit.
Crontab will look like this :
55 * * * * /home/cronuser/exportAWSobjects.sh > /home/cronuser/FWdefinitions.txt ; /usr/bin/scp -i /home/cronuser/.ssh/id_rsa /home/cronuser/FWdefinitions.txt user@server:/home/user/operations/AWSRanges/FWdefinitions.txt

