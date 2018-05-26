/*resource "aws_instance" "example" {
ami           = "ami-66506c1c"
instance_type = "t2.micro"
key_name = "${var.key_name}"
tags {
Name = "my-instance"
}
}*/


resource "aws_vpc" "terraformmain" {
    cidr_block = "${var.vpc-fullcidr}"
   #### this 2 true values are for use the internal vpc dns resolution
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
      Name = "My terraform vpc"
    }
}



resource "aws_subnet" "PublicProject" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  cidr_block = "${var.Subnet-Public-Project1-CIDR}"
  tags {
        Name = "PublicProject1"
  }
 availability_zone = "us-east-1a"
}

resource "aws_subnet" "PrivateProject" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  cidr_block = "${var.Subnet-Private-Project1-CIDR}"
  tags {
        Name = "PrivateProject1"
  }
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "gw" {
   vpc_id = "${aws_vpc.terraformmain.id}"
    tags {

        Name = "internet gw terraform generated"
    }
}


resource "aws_network_acl" "all" {
   vpc_id = "${aws_vpc.terraformmain.id}"
    egress {
        protocol = "-1"
        rule_no = 2
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
        protocol = "-1"
        rule_no = 1
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    tags {
        Name = "open acl"
    }
}



  resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  tags {
      Name = "PublicRouteTable"
  }
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"



 }
}


resource "aws_eip" "forNat" {
    vpc      = true
}
resource "aws_nat_gateway" "PublicAZA" {
    allocation_id = "${aws_eip.forNat.id}"
    subnet_id = "${aws_subnet.PublicProject.id}"
    depends_on = ["aws_internet_gateway.gw"]
}





resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  tags {
      Name = "PrivateRouteTable"
  }
  route {
        cidr_block = "0.0.0.0/0"
       nat_gateway_id = "${aws_nat_gateway.PublicAZA.id}"
  }
}




/*resource "aws_eip" "forNat" {
    vpc      = true
}
resource "aws_nat_gateway" "PublicAZA" {
    allocation_id = "${aws_eip.forNat.id}"
    subnet_id = "${aws_subnet.PublicProject.id}"
    depends_on = ["aws_internet_gateway.gw"]
}*/

resource "aws_route_table_association" "public" {
    subnet_id = "${aws_subnet.PublicProject.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
    subnet_id = "${aws_subnet.PrivateProject.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_security_group" "FrontEnd" {
  name = "FrontEnd"
  tags {
        Name = "FrontEnd"
  }
  description = "ONLY HTTP CONNECTION INBOUD"
  vpc_id = "${aws_vpc.terraformmain.id}"

  ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
  }




ingress {
from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_instance" "example" {
ami         = "ami-66506c1c"
instance_type = "t2.micro"
 subnet_id = "${aws_subnet.PublicProject.id}"
associate_public_ip_address = "true"
  vpc_security_group_ids = ["${aws_security_group.FrontEnd.id}"]
key_name = "${var.key_name}"
tags {
Name = "Jenkins job"
}
}

