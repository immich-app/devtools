package controller

import (
	"context"

	appsv1 "k8s.io/api/apps/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"
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

	serverController := &ComponentController{
		ComponentName: "immich-server",
		Image:         "ghcr.io/immich-app/immich-server",
		Port:          3001,
		Args:          []string{"start.sh", "immich"},
	}

	res, err := serverController.Reconcile(ctx, r, preview)
	if err != nil {
		return res, err
	}

	//TODO: Figure out the details of what Result needs to be returned when
	return res, err
}

// SetupWithManager sets up the controller with the Manager.
func (r *PreviewReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&devtoolsv1alpha1.Preview{}).
		Owns(&appsv1.Deployment{}).
		Complete(r)
}
