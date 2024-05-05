package controller

import (
	"context"
	"fmt"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/api/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/apimachinery/pkg/util/intstr"
	"maps"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log"
	"strings"

	devtoolsv1alpha1 "github.com/immich-app/devtools/tools/preview-operator/api/v1alpha1"
)

type ComponentVolumeSpec struct {
	Name      string
	MountPath string
	PVCName   string
}

type ComponentController struct {
	ComponentName string
	Image         string
	Tag           string
	Port          int32
	Args          []string
	Env           []corev1.EnvVar
	Volumes       *ComponentVolumeSpec
}

func (c *ComponentController) Reconcile(ctx context.Context, r *PreviewReconciler, preview *devtoolsv1alpha1.Preview) error {
	err := c.reconcileDeployment(ctx, r, preview)
	if err != nil {
		return err
	}

	err = c.reconcileService(ctx, r, preview)
	if err != nil {
		return err
	}

	return nil
}

func (c *ComponentController) reconcileDeployment(ctx context.Context, r *PreviewReconciler, preview *devtoolsv1alpha1.Preview) error {
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
				return err
			}

			return err
		}

		log.Info("Creating a new Deployment",
			"Deployment.Namespace", dep.Namespace, "Deployment.Name", dep.Name)
		if err = r.Create(ctx, dep); err != nil {
			log.Error(err, "Failed to create new Deployment",
				"Deployment.Namespace", dep.Namespace, "Deployment.Name", dep.Name)
			return err
		}

		return nil
	} else if err != nil {
		log.Error(err, "Failed to get Deployment")
		// Let's return the error for the reconciliation be re-trigged again
		return err
	}
	meta.SetStatusCondition(&preview.Status.Conditions, metav1.Condition{Type: typeAvailableDeployment,
		Status: metav1.ConditionTrue, Reason: "Reconciling",
		Message: fmt.Sprintf("Deployment for custom resource (%s) created successfully", preview.Name)})

	if err := r.Status().Update(ctx, preview); err != nil {
		log.Error(err, "Failed to update Preview status")
		return err
	}

	return nil
}

func (c *ComponentController) reconcileService(ctx context.Context, r *PreviewReconciler, preview *devtoolsv1alpha1.Preview) error {
	log := log.FromContext(ctx)

	service := &corev1.Service{}
	err := r.Get(ctx, types.NamespacedName{Name: c.name(preview), Namespace: preview.Namespace}, service)
	if err != nil && apierrors.IsNotFound(err) {
		svc, err := c.service(r, preview)
		if err != nil {
			log.Error(err, "Failed to define new Service resource for "+c.ComponentName)
			return err
		}

		log.Info("Creating a new Service",
			"Service.Namespace", svc.Namespace, "Service.Name", svc.Name)
		if err = r.Create(ctx, svc); err != nil {
			log.Error(err, "Failed to create new Service",
				"Service.Namespace", svc.Namespace, "Service.Name", svc.Name)
			return err
		}

		return nil
	} else if err != nil {
		log.Error(err, "Failed to get Service")
		return err
	}

	return nil
}

func (c *ComponentController) name(preview *devtoolsv1alpha1.Preview) string {
	return preview.Name + "-" + c.ComponentName
}

func (c *ComponentController) selectorLabels(preview *devtoolsv1alpha1.Preview) map[string]string {
	return map[string]string{
		"app.kubernetes.io/name":     c.ComponentName,
		"app.kubernetes.io/instance": preview.Name,
	}
}

func (c *ComponentController) labels(preview *devtoolsv1alpha1.Preview) map[string]string {
	var imageTag string
	image := c.image()
	imageTag = strings.Split(image, ":")[1]

	labels := map[string]string{
		"app.kubernetes.io/version":    imageTag,
		"app.kubernetes.io/part-of":    "preview-operator",
		"app.kubernetes.io/created-by": "controller-manager",
	}
	maps.Copy(labels, c.selectorLabels(preview))
	return labels
}

func (c *ComponentController) image() string {
	return c.Image + ":" + c.Tag
}

func (c *ComponentController) deployment(r *PreviewReconciler, preview *devtoolsv1alpha1.Preview) (*appsv1.Deployment, error) {
	ls := c.labels(preview)

	replicas := int32(1)

	var volumes []corev1.Volume
	if c.Volumes != nil {
		volumes = append(volumes, corev1.Volume{
			Name: c.Volumes.Name,
			VolumeSource: corev1.VolumeSource{
				PersistentVolumeClaim: &corev1.PersistentVolumeClaimVolumeSource{
					ClaimName: c.Volumes.PVCName,
				},
			},
		})
	}

	containerSpec := c.containerSpec()

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
					Containers: []corev1.Container{containerSpec},
					Volumes:    volumes,
				},
			},
		},
	}

	if err := ctrl.SetControllerReference(preview, dep, r.Scheme); err != nil {
		return nil, err
	}
	return dep, nil
}

func (c *ComponentController) containerSpec() corev1.Container {
	image := c.image()

	var volumeMounts []corev1.VolumeMount
	if c.Volumes != nil {
		volumeMounts = append(volumeMounts, corev1.VolumeMount{
			Name:      c.Volumes.Name,
			MountPath: c.Volumes.MountPath,
		})
	}

	containerSpec := corev1.Container{
		Image:           image,
		Name:            c.ComponentName,
		ImagePullPolicy: corev1.PullAlways,
		Ports: []corev1.ContainerPort{{
			ContainerPort: c.Port,
			Name:          "http",
		}},
		Args:         c.Args,
		Env:          c.Env,
		VolumeMounts: volumeMounts,
	}

	return containerSpec
}

func (c *ComponentController) service(r *PreviewReconciler, preview *devtoolsv1alpha1.Preview) (*corev1.Service, error) {
	svc := &corev1.Service{
		ObjectMeta: metav1.ObjectMeta{
			Name:      c.name(preview),
			Namespace: preview.Namespace,
		},
		Spec: corev1.ServiceSpec{
			Ports: []corev1.ServicePort{
				{
					Name: "http",
					Port: c.Port,
					TargetPort: intstr.IntOrString{
						Type:   intstr.String,
						StrVal: "http",
					}},
			},
			Selector: c.selectorLabels(preview),
		},
	}

	if err := ctrl.SetControllerReference(preview, svc, r.Scheme); err != nil {
		return nil, err
	}

	return svc, nil
}
