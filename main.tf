terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "gitlab_ce" {
  name         = "gitlab/gitlab-ce:latest"
  keep_locally = true
}

locals {
  gitlab_config = <<-EOT
    external_url '${var.gitlab_external_url}';
    gitlab_rails['lfs_enabled'] = true;

    gitlab_rails['smtp_enable'] = true;
    gitlab_rails['smtp_address'] = "email-smtp.${var.aws_region}.amazonaws.com";
    gitlab_rails['smtp_port'] = 587;
    gitlab_rails['smtp_user_name'] = "${module.gitlab_email.smtp_username}";
    gitlab_rails['smtp_password'] = "${module.gitlab_email.smtp_password}";
    gitlab_rails['smtp_domain'] = "${var.email_domain}";
    gitlab_rails['smtp_authentication'] = "login";
    gitlab_rails['smtp_enable_starttls_auto'] = true;
    gitlab_rails['smtp_tls'] = false;
    gitlab_rails['gitlab_email_from'] = "gitlab@${var.email_domain}";
    gitlab_rails['gitlab_email_reply_to'] = "noreply@${var.email_domain}";
    gitlab_rails['gitlab_email_display_name'] = "GitLab";
    gitlab_rails['time_zone'] = "Asia/Singapore";

    # GitLab Workhorse configuration
    gitlab_workhorse['listen_network'] = "unix";
    gitlab_workhorse['listen_addr'] = "/var/opt/gitlab/gitlab-workhorse/socket";
    gitlab_workhorse['auth_socket'] = "/var/opt/gitlab/gitlab-rails/sockets/gitlab.socket";
    gitlab_workhorse['enable'] = true;

    # Puma configuration
    puma['enable'] = true;
    puma['listen'] = '/var/opt/gitlab/gitlab-rails/sockets/gitlab.socket';
    puma['worker_processes'] = 2;
    puma['worker_timeout'] = 60;
    puma['min_threads'] = 4;
    puma['max_threads'] = 16;


    # Nginx configuration
    nginx['enable'] = true;
    nginx['listen_port'] = 80;
    nginx['proxy_set_headers'] = {
      "Host" => "$http_host",
      "X-Real-IP" => "$remote_addr",
      "X-Forwarded-For" => "$proxy_add_x_forwarded_for",
      "X-Forwarded-Proto" => "$scheme"
    };

    # System settings
    postgresql['enable'] = true;
    redis['enable'] = true;
    prometheus_monitoring['enable'] = true;
  EOT
}

resource "docker_container" "gitlab_ce" {
  name = "gitlab-ce"
  /* latest = repo_digest */
  image = docker_image.gitlab_ce.repo_digest

  ports {
    internal = 80
    external = 8080
  }

  ports {
    internal = 443
    external = 8443
  }

  ports {
    internal = 22
    external = 2222
  }

  # Add hostname
  hostname = "gitlab.local"
  # Resource limits
  memory    = 4096
  memory_swap = 4096

  env = [
    "GITLAB_OMNIBUS_CONFIG=${local.gitlab_config}"
  ]

  volumes {
    container_path = "/etc/gitlab"
    host_path      = abspath("${path.module}/gitlab/etc")
  }

  volumes {
    container_path = "/var/log/gitlab"
    host_path      = abspath("${path.module}/gitlab/log")
  }

  volumes {
    container_path = "/var/opt/gitlab"
    host_path      = abspath("${path.module}/gitlab/data")
  }

  restart = "unless-stopped"

  # Health check can be added for more robust startup before dependent resources
  #   healthcheck {
  #     test     = ["CMD", "curl", "-f", "http://localhost:8080/-/health"]
  #     interval = "30s"
  #     timeout  = "10s"
  #     retries  = 5
  #   }

  #   healthcheck {
  #     test         = ["CMD", "/opt/gitlab/bin/gitlab-healthcheck", "--fail"]
  #     interval     = "60s"
  #     timeout      = "30s"
  #     start_period = "180s"
  #     retries      = 5
  #   }


  # Add extra hosts if needed
#   extra_hosts = ["gitlab.local:127.0.0.1"]
}
