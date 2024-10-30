# Thanks to https://github.com/tonyprawiro/aws-msad-terraform.  Good work, man!

resource "aws_ssm_document" "directory_client_doc" {
	name  = "directory_client_default_doc"
	document_type = "Command"

	content = <<DOC
{
        "schemaVersion": "1.0",
        "description": "Join an instance to a domain",
        "runtimeConfig": {
           "aws:domainJoin": {
               "properties": {
                   "directoryId": "${aws_directory_service_directory.default.id}",
                   "directoryName": "${aws_directory_service_directory.default.name}",
                   "dnsIpAddresses": [ 
                       "${aws_directory_service_directory.default.dns_ip_addresses[0]}", 
                       "${aws_directory_service_directory.default.dns_ip_addresses[1]}" 
                   ]
               }
           }
        }
}
DOC

	depends_on = ["aws_directory_service_directory.default"]
}
