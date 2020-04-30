# Eng47-FinalProject-LB--AS

Our project aimed to create a multi-AZ environment on AWS for a javascript application. This architecture needed to make use of a load
balancer and an auto scaler for this node application to be hosted on. Once the principles of building this architecture were understood we
directed our focus to automate the construction of this AWS architecture using the terraform orchestration tool.

Initially, we started to create our terraform file using an example we had made in a previous project, we aimed to create our multi-AZ
AWS platform using a modular terraform design. Since we are working with a two-tier architecture we made separate modules to handle the app and the DB. 

Firstly we wrote the resource to create a vpc, this is where we were first able to utilise variables to fill the CIDR block requirement. 
Next, the internet gateway was configured to allow access for users.

Now that our vpc was ready we were able to create the necessary subnets for the two tiers, this is where we created our two folders 
/app_tier and db_tier to handle the variables for both the app and db. For both the app and db subnets the vpc id was added so that the
subnets would be allocated to the created vpc automatically. The ami for both the db and app were created using packer from a previous
project.

Within the respective terraform files for the app and the db the security groups for the instances that would ultimately be spun up.
For the app instances, we allowed inbound traffic on port 80 so that the app could be accessed publicly. Since the db would exist on a private
subnet the security group was created with some differences, the security group and NACL would allow inbound traffic on port 27017 so that
the app could communicate to the db and outbound of all ephemeral ports back to the app. This ensured that the db would only communicate with
the app and there was no access from outside to the db.

For the app we wanted an instance of the node app to be running on all three availability zones within the eu-west-1 region on AWS,
therefore we found that each of these availability zones needed their subnets. Initially, we had some difficulties achieving this as we
did not understand how to do this using all the same configurations across the different zones. We solved this by writing three separate resources for each of the subnets and using the stored variables to populate the configurations. We were also sure to enable the automapping of a public IP upon launch of the subnets as to allow access from outside.

Once we had the four subnets set up (3 apps, 1 db) we wanted to configure auto-scaling so it could monitor our running instances and scale
up and down the number of running instances to account for heavy and low traffic and/or if any instances stopped working. This proved difficult to configure in terraform at first because we could not configure the auto scaler to effectively communicate with all three
subnets and spin up EC2 environments in all 3. However, once we had correctly set up the zone identifier for each subnet we had a functioning
auto scaler ready on out architecture.

The last big challenge for our multi-AZ project was to configure a load balancer within AWS via terraform. The load balancer would distribute traffic to all instances in the regions availability zone so that no one zone is overwhelmed by requests. This was the biggest
challenge in our project as we needed traffic to be routed to the instances within the zones through the load balancer. initially, we struggled to find a way for the load balancer to connect to the three subnets, we found that we must create target groups between the auto scaler and the load balancer so that the load balancer could handle traffic in and the auto scaler could respond accordingly, however,
we could not get the load balancer to route traffic to the subnets without adding a listener to it. Once we found this we were able to configure the load balancer to listen on port 80 and send traffic to the desired subnet.

With all these problems solved we had created a functioning architecture for an app and db to run on, this architecture has an auto scaler 
and load balancer incorporated into their design and all of its configuration is handled by terraform.
