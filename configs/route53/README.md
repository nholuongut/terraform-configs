### Route 53 Zones
Each public zone that gets created with terraform will consist of
the zone itself, a TXT record called "creator," a cloudwatch 
log group in us-east-1, and a query log resource that ties the 
zone to a cloudwatch logging policy and to the log group, itself.

See the modules directory in this project if you're curious.

### CLI tricks

Try planning, first!  Planning will let you know which changes
terraform intends to make.
```
terraform plan
```

To create an individual zone, try this:
```
terraform apply -target=module.EXAMPLE.aws_route53_record.txt
```

To see which resources have been created, try:
```
terraform state list
```
