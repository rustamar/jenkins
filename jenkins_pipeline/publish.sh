
# this script is used for deploying custom page index.html to apache server which is located
# on the same node where jenkins

# set silent shell
set +x

# get ip
ip=```curl -s http://ipecho.net/plain/;echo```

# get custom page (could be done with scm too...)
curl -L -O https://raw.githubusercontent.com/rustamar/jenkins/master/publish_stuff/index.html

# copy the page to the apache server
scp -o StrictHostKeyChecking=no ./index.html core@${ip}:/var/httpd/
