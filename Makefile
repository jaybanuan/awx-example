##############################################################################
# Variables



##############################################################################
# Targets

.PHONY: clean
clean:
	echo "do nothing."


.PHONY: apply-manifest
apply-manifest:
	kubectl apply -n awx -f kubernetes/manifest.yml


.PHONY: service-url
service-url:
	minikube service webapp -n awx --url


.PHONY: dashboard
dashboard:
	minikube dashboard &
