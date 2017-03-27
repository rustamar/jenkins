output "jenkins" {
  value = "${aws_alb.jenkins.dns_name}"
}

#output "httpd" {
#  value = "${aws_alb.httpd.dns_name}"
#}
