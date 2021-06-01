# User Management Microservice

REST API for user management microservice with swagger UI is available on 
### https://users.skycomposer.net/usermgmt/swagger-ui/index.html

# Microservices Deployment on AWS with Terraform and K3S:

## Step 01 - Setup terraform account on AWS 
#### Skip to Step 02, if you already have working Terraform account with all permissions

#### Setting Up an AWS Operations Account

 - Log in to your AWS management console with your root user credentials. Once you’ve logged in, you should be presented with a list of AWS services. Find and select the IAM service.

 - Select the Users link from the IAM navigation menu on the lefthand side of the screen. Click the Add user button to start the IAM user creation process

 - Enter **ops-account** in the User name field. We also want to use this account to acccess the CLI and API, so select “Programmatic access” as the AWS “Access type”

-  Select “Attach existing policies directly” from the set of options at the top. Search for a policy called IAMFullAccess and select it by ticking its checkbox

- If everything looks OK to you, click the Create user button.

#### Access key and secret key

- Before we do anything else, we’ll need to make a note of our new user’s keys. Click the Show link and copy and paste both the “**Access key ID**” and the “**Secret access key**” into a temporary file. We’ll use both of these later in this section with our automated pipeline. Be careful with this key material as it will give whoever has it an opportunity to create resources in your AWS environment—at your expense.

- Make sure you take note of the access key ID and the secret access key that were generated before you leave this screen. You’ll need them later.

- We have now created a user called **ops-account** with permission to make IAM changes. 

#### Configure the AWS CLI

```
$ aws configure
AWS Access Key ID [****************AMCK]: AMIB3IIUDHKPENIBWUVGR
AWS Secret Access Key [****************t+ND]: /xd5QWmsqRsM1Lj4ISUmKoqV7/...
Default region name [None]: eu-west-2
Default output format [None]: json
```

You can test that you’ve configured the CLI correctly by listing the user accounts that have been created. Run the iam list-users command to test your setup:

```
$ aws iam list-users
{
    "Users": [
        {
            "Path": "/",
            "UserName": "admin",
            "UserId": "AYURIGDYE7PXW3QCYYEWM",
            "Arn": "arn:aws:iam::842218941332:user/admin",
            "CreateDate": "2019-03-21T14:01:03+00:00"
        },
        {
            "Path": "/",
            "UserName": "ops-account",
            "UserId": "AYUR4IGBHKZTE3YVBO2OB",
            "Arn": "arn:aws:iam::842218941332:user/ops-account",
            "CreateDate": "2020-07-06T15:15:31+00:00"
        }
    ]
}
```

If you’ve done everything correctly, you should see a list of your AWS user accounts. That indicates that AWS CLI is working properly and has access to your instance. Now, we can set up the permissions our operations account will need.

#### Setting Up AWS Permissions

The first thing we’ll do is make the ops-account user part of a new group called Ops-Accounts. That way we’ll be able to assign new users to the group if we want them to have the same permissions. Use the following command to create a new group called Ops-Accounts:

```
$ aws iam create-group --group-name Ops-Accounts
```
$ aws iam create-group --group-name Ops-Accounts

If this is successful, the AWS CLI will display the group that has been created:

```
{

    "Group": {
        "Path": "/",
        "GroupName": "Ops-Accounts",
        "GroupId": "AGPA4IGBHKZTGWGQWW67X",
        "Arn": "arn:aws:iam::842218941332:group/Ops-Accounts",
        "CreateDate": "2020-07-06T15:29:14+00:00"
    }
}
```

Now, we just need to add our user to the new group. Use the following command to do that:

```
$ aws iam add-user-to-group --user-name ops-account --group-name Ops-Accounts
````

If it works, you’ll get no response from the CLI.

Next, we need to attach a set of permissions to our Ops-Account group. 

```
$ aws iam attach-group-policy --group-name Ops-Accounts\
 --policy-arn arn:aws:iam::aws:policy/IAMFullAccess &&\
aws iam attach-group-policy --group-name Ops-Accounts\
 --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess &&\
aws iam attach-group-policy --group-name Ops-Accounts\
 --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess &&\
aws iam attach-group-policy --group-name Ops-Accounts\
 --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy &&\
aws iam attach-group-policy --group-name Ops-Accounts\
 --policy-arn arn:aws:iam::aws:policy/AmazonEKSServicePolicy &&\
aws iam attach-group-policy --group-name Ops-Accounts\
 --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess &&\
aws iam attach-group-policy --group-name Ops-Accounts\
 --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess &&\
aws iam attach-group-policy --group-name Ops-Accounts\
 --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

```

With the new policy created, all that’s left is to attach it to our user group. Run the following command, replacing the token we’ve called {YOUR_POLICY_ARN} with the ARN from your policy:

```
$ aws iam attach-group-policy --group-name Ops-Accounts \
   --policy-arn {YOUR_POLICY_ARN}
```

#### Creating an S3 Backend for Terraform

- If you are hosting your bucket in the us-east-1 region, use the following command:

```
$ aws s3api create-bucket --bucket {YOUR_S3_BUCKET_NAME} --region us-east-1
```

- If you are hosting the s3 bucket in a region other than us-east-1, use the following command:

```
$ aws s3api create-bucket --bucket {YOUR_S3_BUCKET_NAME} \
> --region {YOUR_AWS_REGION} --create-bucket-configuration \
> LocationConstraint={YOUR_AWS_REGION}
```




## Step-02: Setup your local Terraform environment

- create private and public SSH Keys. Terraform will use them to run scripts on your EC2 instances:

```
    ssh-keygen -t rsa
````

- go to "**terraform**" folder of this github repository

- create file "**terraform.auto.tfvars**" in "**terraform**" folder:

```
access_ip = "0.0.0.0/0"
public_key_path = "/Users/dddd/.ssh/keymtc.pub"
private_key_path = "/Users/dddd/.ssh/keymtc"
certificate_arn = "arn:aws:acm:ddddddddddddddddddddf"

#--db vars --
dbname     = "rancher"
dbuser     = "bobby"
dbpassword = "s00p3rS3cr3t"
```

- make sure you provide correct path for "**public_key_path**" and "**private_key_path**"

- make sure you provide correct "**certifcate_arn**" for your AWS certificate, registered to your domain. You need to register your domain and create certificate for your domain in AWS

- replace "**skyglass-terraform**" in "**backends.tf**" with the name of your S3 bucket, created in "**Step 01**"


- run the following commands:

```
terraform init

terraform validate

terraform apply --auto-approve

``` 

- terraform will automatically create KUBECONFIG file, so you can switch to your created K3S Kubernetes cluster by using
```
export KUBECONFIG=./ks3/k3s.yaml
``` 





## Step-03: Create "user-management:1.0.0" docker image and push it to docker hub

- go back to the root directory of this github repository

- replace "**skyglass**" in "**pom.xml**"
```
<repository>skyglass/${project.name}</repository>
``` 

with the name of your docker hub repository

-  for example, if "**test**" is the name of your docker hub repository, then run: 
```
mvn clean install
docker push test/user-management:1.0.0
````



## Step-04: Deploy "user-management" microservice to AWS:

- go to "**EC2 -> Load Balancers**" in your AWS Console

- copy DNS name of your load balancer

- go to "**Route53 -> Hosted Zones -> Your Hosted Zone -> Create Record**"

- let's assume that the name of your domain is "**test.com**" and "**DNS name**" of your LoadBalancer is "**mtc-loadbalancer.com**"

- create "**CNAME**" record with the name "**users.test.com**" and the value "**mtc-loadbalancer.com**"

- go to "**k3s-traefik**" folder of this github repository

- Edit "**200-usermgmt.yaml**": replace "**skyglass/user-management:1.0.0**" with the name of your docker image

- Edit "**0006-traefik-service.yaml**": set "**service.beta.kubernetes.io/aws-load-balancer-ssl-cert**" to cerfiticate_arn of your AWS Certificate

- go back to "**terraform**" directory and run the following commands:
``` 
export KUBECONFIG=./ks3/k3s.yaml

kubectl apply -f ../k3s-traefik
``` 

- let's assume that the name of your "**CNAME**" record is "**users.test.com**" 

- let's assume that "**DNS name**" of your Load Balancer is "**mtc-loadbalancer.com**"

- let's assume that you correctly registered your domain, created hosted zone, registered AWS SSL Certificate for your domain and created "**CNAME**" record with the name "**users.test.com**" and the value "**mtc-loadbalancer.com**"

- go to "**https://users.test.com/usermgmt/swagger-ui/index.html"

- you should see successfully loaded "**Swagger UI**" page

- go to "**https://users.test.com/whoami"

- you should see successfully loaded "**WhoAmI**" page




### Congratulations! You sucessfully created Minimal Kubernetes Cluster on AWS with Terraform and K3S!
### Now you can deploy your own docker containers to this cluster with minimal costs from AWS!
### You significantly reduced your AWS bills by removing AWS EKS and NAT gateway!
##### You implemented Traefik Ingress Controller, which acts as a Gateway Load Balancer for your microservices
##### Now you can add any number of microservices to your K3S Kubernetes Cluster and use only one Gateway Load Balancer for all these microservice 


## Step-05: Clean-Up:

```
terraform destroy --auto-approve  
```
