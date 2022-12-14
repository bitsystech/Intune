# There can be a requirement to launch an app for any purpose. 
# For us, it was enrolment notification GUI to tell users what's happening 
# We use BitNotify to show GUI & inform end users about what is installing
# BitNotify Link: https://github.com/bitsystech/BitNotify
# Original idea from SystandDeploy guy #

start-process companyportal:ApplicationId=YourAppID
sleep 10
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[System.Windows.Forms.SendKeys]::SendWait("^{i}")
