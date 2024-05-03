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
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	devtoolsv1alpha1 "github.com/immich-app/devtools/tools/preview-operator/api/v1alpha1"
)

const (
	typeAvailableDeployment = "Available"
)

// PreviewReconciler reconciles a Preview object
type PreviewReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

//+kubebuilder:rbac:groups=devtools.immich.app,resources=previews,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=devtools.immich.app,resources=previews/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=devtools.immich.app,resources=previews/finalizers,verbs=update

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the Preview object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.16.3/pkg/reconcile
func (r *PreviewReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx)

	//Get Preview object
	preview := &devtoolsv1alpha1.Preview{}
	err := r.Get(ctx, req.NamespacedName, preview)
	if err != nil {
		if apierrors.IsNotFound(err) {
			// If the custom resource is not found then, it usually means that it was deleted or not created
			// In this way, we will stop the reconciliation
			log.Info("preview resource not found. Ignoring since object must be deleted")
			return ctrl.Result{}, nil
		}
		// Error reading the object - requeue the request.
		log.Error(err, "Failed to get preview")
		return ctrl.Result{}, err
	}

	//Reconcile immich-server deployment
	server := &appsv1.Deployment{}
	err = r.Get(ctx, types.NamespacedName{Name: preview.Name, Namespace: preview.Namespace}, server)
	if err != nil && apierrors.IsNotFound(err) {
		// Define a new deployment
		dep, err := r.deploymentForServer(preview)
		if err != nil {
			log.Error(err, "Failed to define new Deployment resource for immich-server")

			// The following implementation will update the status
			meta.SetStatusCondition(&preview.Status.Conditions, metav1.Condition{Type: typeAvailableDeployment,
				Status: metav1.ConditionFalse, Reason: "Reconciling",
				Message: fmt.Sprintf("Failed to create immich-server Deployment for the custom resource (%s): (%s)", preview.Name, err)})

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

	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *PreviewReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&devtoolsv1alpha1.Preview{}).
		Complete(r)
}

func nameForServer(preview *devtoolsv1alpha1.Preview) string {
	return preview.Name + "-server"
}

func labelsForServer(preview *devtoolsv1alpha1.Preview) map[string]string {
	var imageTag string
	image := imageForServer(preview)
	imageTag = strings.Split(image, ":")[1]
	name := nameForServer(preview)

	return map[string]string{"app.kubernetes.io/name": "immich-server",
		"app.kubernetes.io/instance":   name,
		"app.kubernetes.io/version":    imageTag,
		"app.kubernetes.io/part-of":    "preview-operator",
		"app.kubernetes.io/created-by": "controller-manager",
	}
}

func imageForServer(preview *devtoolsv1alpha1.Preview) string {
	tag := preview.Spec.Immich.Tag
	return "ghcr.io/immich-app/immich-server:" + tag
}

func (r *PreviewReconciler) deploymentForServer(preview *devtoolsv1alpha1.Preview) (*appsv1.Deployment, error) {
	ls := labelsForServer(preview)
	image := imageForServer(preview)

	replicas := preview.Spec.Immich.Server.Replicas

	dep := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      preview.Name,
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
						Name:            "immich-server",
						ImagePullPolicy: corev1.PullAlways,
						Ports: []corev1.ContainerPort{{
							ContainerPort: 3001,
							Name:          "http",
						}},
						Args: []string{"start.sh", "immich"},
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
