##############################################################################
# Variables



##############################################################################
# Targets

.PHONY: clean
clean:
	echo "do nothing."


.PHONY: dashboard
dashboard:
	minikube dashboard &


.PHONY: awx-service-url
awx-service-url:
	minikube service awx-demo-service -n awx --url


.PHONY: apply-manifest
apply-manifest:
	kubectl apply -n awx -f kubernetes/manifest.yml


.PHONY: webapp-service-url
webapp-service-url:
	minikube service webapp -n awx --url
