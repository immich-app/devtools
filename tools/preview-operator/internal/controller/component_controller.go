package controller

import (
	"context"
	"fmt"
	"strings"
	"time"

	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/api/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"

	devtoolsv1alpha1 "github.com/immich-app/devtools/tools/preview-operator/api/v1alpha1"
)

type ComponentController struct {
	ComponentName string
	Image         string
	Port          int32
	Args          []string
}

func (c *ComponentController) Reconcile(ctx context.Context, r *PreviewReconciler, preview *devtoolsv1alpha1.Preview) (ctrl.Result, error) {
	log := log.FromContext(ctx)

	deployment := &appsv1.Deployment{}
	err := r.Get(ctx, types.NamespacedName{Name: c.name(preview), Namespace: preview.Namespace}, deployment)
	if err != nil && apierrors.IsNotFound(err) {
		dep, err := c.deployment(r, preview)
		if err != nil {
			log.Error(err, "Failed to define new Deployment resource for "+c.ComponentName)

			// The following implementation will update the status
			meta.SetStatusCondition(&preview.Status.Conditions, metav1.Condition{Type: typeAvailableDeployment,
				Status: metav1.ConditionFalse, Reason: "Reconciling",
				Message: fmt.Sprintf("Failed to create (%s) Deployment for the custom resource (%s): (%s)", c.ComponentName, preview.Name, err)})

			if err := r.Status().Update(ctx, preview); err != nil {
				log.Error(err, "Failed to update Preview status")
				return ctrl.Result{}, err
			}

			return ctrl.Result{}, err
		}

		log.Info("Creating a new Deployment",
			"Deployment.Namespace", dep.Namespace, "Deployment.Name", dep.Name)
		if err = r.Create(ctx, dep); err != nil {
			log.Error(err, "Failed to create new Deployment",
				"Deployment.Namespace", dep.Namespace, "Deployment.Name", dep.Name)
			return ctrl.Result{}, err
		}

		// Deployment created successfully
		// We will requeue the reconciliation so that we can ensure the state
		// and move forward for the next operations
		return ctrl.Result{RequeueAfter: time.Minute}, nil
	} else if err != nil {
		log.Error(err, "Failed to get Deployment")
		// Let's return the error for the reconciliation be re-trigged again
		return ctrl.Result{}, err
	}
	meta.SetStatusCondition(&preview.Status.Conditions, metav1.Condition{Type: typeAvailableDeployment,
		Status: metav1.ConditionTrue, Reason: "Reconciling",
		Message: fmt.Sprintf("Deployment for custom resource (%s) created successfully", preview.Name)})

	if err := r.Status().Update(ctx, preview); err != nil {
		log.Error(err, "Failed to update Preview status")
		return ctrl.Result{}, err
	}

	return ctrl.Result{}, err
}

func (c *ComponentController) name(preview *devtoolsv1alpha1.Preview) string {
	return preview.Name + c.ComponentName
}

func (c *ComponentController) labels(preview *devtoolsv1alpha1.Preview) map[string]string {
	var imageTag string
	image := c.image(preview)
	imageTag = strings.Split(image, ":")[1]
	name := c.name(preview)

	return map[string]string{"app.kubernetes.io/name": "immich-server",
		"app.kubernetes.io/instance":   name,
		"app.kubernetes.io/version":    imageTag,
		"app.kubernetes.io/part-of":    "preview-operator",
		"app.kubernetes.io/created-by": "controller-manager",
	}
}

func (c *ComponentController) image(preview *devtoolsv1alpha1.Preview) string {
	tag := preview.Spec.Immich.Tag
	return c.Image + ":" + tag
}

func (c *ComponentController) deployment(r *PreviewReconciler, preview *devtoolsv1alpha1.Preview) (*appsv1.Deployment, error) {
	ls := c.labels(preview)
	image := c.image(preview)

	replicas := int32(1)

	dep := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      c.name(preview),
			Namespace: preview.Namespace,
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: &replicas,
			Selector: &metav1.LabelSelector{
				MatchLabels: ls,
			},
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: ls,
				},
				Spec: corev1.PodSpec{
					Containers: []corev1.Container{{
						Image:           image,
						Name:            c.ComponentName,
						ImagePullPolicy: corev1.PullAlways,
						Ports: []corev1.ContainerPort{{
							ContainerPort: c.Port,
							Name:          "http",
						}},
						Args: c.Args,
						//TODO: env, volume
					}},
				},
			},
		},
	}

	if err := ctrl.SetControllerReference(preview, dep, r.Scheme); err != nil {
		return nil, err
	}
	return dep, nil
}
