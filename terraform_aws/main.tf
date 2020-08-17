
provider "aws" {
    region = "us-east-2"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}" 
}

resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16"
    tags ={
        name = "Main VPC"
    }
}

resource "aws_internet_gateway" "main" { 
    vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.1.1.0/24"
    availability_zone= "us-east-2a"
}

resource "aws_route_table" "default"{
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "main" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.default.id
}

resource "aws_network_acl" "allowall" {
    vpc_id = aws_vpc.main.id 

    #Allow All Out
    egress {
        protocol = "-1"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0    
    }
    #Allow All In
    ingress {
        protocol = "-1"
        rule_no = 200
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
}

resource "aws_security_group" "allowall" {
    name = "Main VPC Allow All"
    description = "Allows All traffic"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8200
        to_port = 8200
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_eip" "webserver" {
    instance = aws_instance.webserver.id 
    vpc = true  
    depends_on = [aws_internet_gateway.main]
}


resource "aws_key_pair" "default" {
    key_name = "ubuntu"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcvwIgTaxphl90fv1e5MKxBNCKuCt9u97g6iqXOZ3T2CcJXAvz29i4QL25E55Wad37jbgMTvCJAyTAVgOKZ9TyYAoNMjJNkKlwH9xuAWCV9HcN74ACSeafQ8+ex6xKWohF725Ega3StAehHtucQwCF8Ae+rKkqlWHDylwLIElCxvKR/NhRcWC6xP42h1NkbYFn8iLtL85KXbobhfgnM+U9sA79vKLQl+6TOaqGZOKgqH1QHSEpW28Y8g0OsWI/TPIn3pGf2QfIShRIZUrSjgzEDbsLZHnIDz4s7UHqsmVA9GXh22tzHT6Cu6uzPwDTf3Ea7BjZ1BJBEqAmNbpNWQamLOc9aJ3JJgz8Lm/wPnAc9CoTJICZSg16aBkgFWohyh6mfj3TiljZ8bulDp4Wl9C5Scu4y53Pti51fhCX1mKnmqVNKOjxlbIS6h/b6PYXJRR3zpXjeKlzn2xuHr5cAfEg70Vtu3YleZo3Xti96ahSRvsCNkyhlZ2cvi+gOOf3bxU= ubuntu"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "webserver" {
    ami =  "${data.aws_ami.ubuntu.id}"
    availability_zone = "us-east-2a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.default.key_name
    vpc_security_group_ids = [aws_security_group.allowall.id]
    subnet_id = aws_subnet.main.id
    associate_public_ip_address = true
 
 
  provisioner "remote-exec" {
    inline = [
      "mkdir /home/${var.ssh_user}/ansible",
    ]

    connection {
      host        = self.public_ip  
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }
  provisioner "file" {
    source      = "../ansible/vault.yml"
    destination = "/home/${var.ssh_user}/ansible/vault.yml"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
        "sudo apt update",
        "sudo apt-get -y install python",
        "sudo apt-get -y install software-properties-common",
        "sudo apt-add-repository --yes --update ppa:ansible/ansible",
        "sudo apt-get -y install ansible",
        "cd ansible; ansible-playbook -vvv -c local -i \"localhost,\" vault.yml"
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }
  #Don't comment out this next line.
}
