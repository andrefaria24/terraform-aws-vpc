variables {
  region                 = "us-east-2"
  prefix                 = "tftest"
  env                    = "demo"
  vpc_cidr               = "10.0.0.0/8"
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs   = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones     = ["us-east-2a", "us-east-2b", "us-east-2c"]
  enable_nat_gateway     = true
  single_nat_gateway     = false
  create_private_subnets = true
  tags                   = { "test" = "value" }
}

run "valid_inputs" {
  module {
    source = "./tests/setup"
  }

  command = plan
}

run "invalid_region" {
  module {
    source = "./tests/setup"
  }

  command = plan
  variables {
    region = "us-central-1"
  }
  expect_failures = [var.region]
}

run "invalid_prefix" {
  module {
    source = "./tests/setup"
  }

  command = plan
  variables {
    prefix = "Invalid_Prefix"
  }
  expect_failures = [var.prefix]
}

run "invalid_env" {
  module {
    source = "./tests/setup"
  }

  command = plan
  variables {
    env = "staging"
  }
  expect_failures = [var.env]
}

run "invalid_vpc_cidr" {
  module {
    source = "./tests/setup"
  }

  command = plan
  variables {
    vpc_cidr = "10.0.0.0/8"
  }
  expect_failures = [var.vpc_cidr]
}

run "invalid_public_subnet_cidrs" {
  module {
    source = "./tests/setup"
  }

  command = plan
  variables {
    public_subnet_cidrs = ["10.0.1.0/16", "invalid_cidr"]
  }
  expect_failures = [var.public_subnet_cidrs]
}

run "invalid_private_subnet_cidrs" {
  module {
    source = "./tests/setup"
  }

  command = plan
  variables {
    private_subnet_cidrs = ["10.0.4.0/16", "invalid_cidr"]
  }
  expect_failures = [var.private_subnet_cidrs]
}

run "invalid_availability_zones" {
  module {
    source = "./tests/setup"
  }

  command = plan
  variables {
    availability_zones = ["us-east-2a", "us-east-2d"]
  }
  expect_failures = [var.availability_zones]
}

run "integration_test" {
  module {
    source = "./tests/setup"
  }

  command = apply

  assert {
    condition     = module.vpc.vpc_id != ""
    error_message = "VPC was not created successfully"
  }


  assert {
    condition     = length(module.vpc.public_subnets) == length(var.public_subnet_cidrs)
    error_message = "Number of created public subnets does not match input"
  }

  assert {
    condition     = length(module.vpc.private_subnets) == length(var.private_subnet_cidrs)
    error_message = "Number of created private subnets does not match input"
  }

  assert {
    condition     = module.vpc.vpc_cidr_block == var.vpc_cidr
    error_message = "Created VPC CIDR block does not match input"
  }
}