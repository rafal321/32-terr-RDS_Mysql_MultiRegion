# 32-terr-RDS_Mysql_MultiRegion
Terraform AWS RDS Mysql Multi region
#_________________________________________________
## RDS Multi region R53 endpoint management:
    https://aws.amazon.com/blogs/database/automate-amazon-aurora-global-database-endpoint-management/
    git clone https://github.com/aws-samples/amazon-aurora-global-database-endpoint-automation.git

pip3 install boto3 --user
````
python3 buildstack.py --template-body 'managed-gdb-cft.yml' --stack-name 'gdb-managed-ep-220921'  --consent-anonymous-data-collect 'yes' --region-list 'eu-west-1,eu-central-1' --features 'all'
python3 create_managed_endpoint.py --cluster-cname-pair '{"raf-devi-global":"writer1.europe.com"}' --hosted-zone-name=europe.com --region-list 'eu-west-1,eu-central-1'
````
#_________________________________________________
