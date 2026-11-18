provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "images" {
  repository_id = "notice-board"
  location      = var.region
  format        = "DOCKER"
  description   = "Notice board images"
}

resource "google_cloud_run_v2_service" "app" {
  name                = "notice-board"
  location            = var.region
  deletion_protection = false

  template {
    service_account = google_service_account.runtime.email
    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.images.repository_id}/app:${var.image_tag}"

      resources {
        cpu_idle = true

        limits = {
          cpu    = "1000m"
          memory = "256Mi"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      scaling,
      template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.app.name
  location = google_cloud_run_v2_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
