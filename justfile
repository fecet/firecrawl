set dotenv-load := true

dirpath := justfile_directory()
build_output := env_var('HOME') / ".cache" / "prefix"
build_path := `realpath ./build`
docker_repo := "harbor.bk8s/aijupyter/firecrawler"
docker_tag := "v1"

default:
    @just --choose

sync target="frp":
    rsync --delete -avP "{{ dirpath }}/" {{ target }}:$(basename "{{ dirpath }}")/ --exclude-from=.rsync_exclude

docker-build repo=docker_repo tag=docker_tag:
  docker build --platform linux/amd64 -t "{{ repo }}:api-{{ tag }}" ./apps/api
  docker build --platform linux/amd64 -t "{{ repo }}:playwright-{{ tag }}" ./apps/playwright-service-ts
  docker push {{ repo }}:api-{{ tag }}  
  docker push {{ repo }}:playwright-{{ tag }}

deploy:
  kubectl create namespace firecrawler || true
  cd {{ dirpath }}/examples/kubernetes/cluster-install && \
    kubectl apply -f configmap.yaml && \
    kubectl apply -f secret.yaml &&  \
    kubectl apply -f playwright-service.yaml && \
    kubectl apply -f api.yaml && \
    kubectl apply -f worker.yaml && \
    kubectl apply -f redis.yaml











