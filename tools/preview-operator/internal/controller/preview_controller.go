package controller

import (
	"context"
	"fmt"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"

	appsv1 "k8s.io/api/apps/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	cnpg "github.com/cloudnative-pg/cloudnative-pg/api/v1"

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
//+kubebuilder:rbac:groups=apps,resources=deployments,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=postgresql.cnpg.io,resources=clusters,verbs=get;list;watch;create;update;patch;delete

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

	database := &cnpg.Cluster{}
	err = r.Get(ctx, types.NamespacedName{Name: clusterName(preview), Namespace: preview.Namespace}, database)
	if err != nil && apierrors.IsNotFound(err) {
		log.Info("Creating database cluster")
		storageClass := "zfs"
		cluster := &cnpg.Cluster{
			ObjectMeta: metav1.ObjectMeta{
				Name:      clusterName(preview),
				Namespace: preview.Namespace,
			},
			Spec: cnpg.ClusterSpec{
				ImageName:             "ghcr.io/tensorchord/cloudnative-pgvecto.rs:14.11-v0.2.0",
				PrimaryUpdateStrategy: cnpg.PrimaryUpdateStrategyUnsupervised,
				Instances:             1,
				PostgresConfiguration: cnpg.PostgresConfiguration{
					AdditionalLibraries: []string{"vectors.so"},
				},
				StorageConfiguration: cnpg.StorageConfiguration{
					Size:         "1Gi",
					StorageClass: &storageClass,
				},
				Bootstrap: &cnpg.BootstrapConfiguration{
					InitDB: &cnpg.BootstrapInitDB{},
				},
			},
		}

		if err := ctrl.SetControllerReference(preview, cluster, r.Scheme); err != nil {
			log.Error(err, "Failed to define new Cluster resource for "+preview.Name)

			// The following implementation will update the status
			meta.SetStatusCondition(&preview.Status.Conditions, metav1.Condition{Type: typeAvailableDeployment,
				Status: metav1.ConditionFalse, Reason: "Reconciling",
				Message: fmt.Sprintf("Failed to create Cluster for the custom resource (%s): (%s)", preview.Name, err)})

			if err := r.Status().Update(ctx, preview); err != nil {
				log.Error(err, "Failed to update Preview status")
				return ctrl.Result{}, err
			}

			return ctrl.Result{}, err
		}

		log.Info("Creating a new Cluster",
			"Cluster.Namespace", cluster.Namespace, "Cluster.Name", cluster.Name)
		if err = r.Create(ctx, cluster); err != nil {
			log.Error(err, "Failed to create new Cluster",
				"Cluster.Namespace", cluster.Namespace, "Cluster.Name", cluster.Name)
			return ctrl.Result{}, err
		}

		// Cluster created successfully
		// We will requeue the reconciliation so that we can ensure the state
		// and move forward for the next operations
		return ctrl.Result{Requeue: true}, nil
	} else if err != nil {
		log.Error(err, "Failed to get Cluster")
		// Let's return the error for the reconciliation be re-trigged again
		return ctrl.Result{}, err
	}

	//TODO: Library volume

	//TODO: Redis

	serverController := &ComponentController{
		ComponentName: "immich-server",
		Image:         "ghcr.io/immich-app/immich-server",
		Port:          3001,
		Args:          []string{"start.sh", "immich"},
		Env:           databaseConnectionEnv(database),
	} //TODO: Redis connection

	err = serverController.Reconcile(ctx, r, preview)
	if err != nil {
		return ctrl.Result{}, err
	}

	//TODO: Microservices

	//TODO: ML

	//TODO: Figure out the details of what Result needs to be returned when
	return ctrl.Result{}, err
}

// SetupWithManager sets up the controller with the Manager.
func (r *PreviewReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&devtoolsv1alpha1.Preview{}).
		Owns(&appsv1.Deployment{}).
		Complete(r)
}

func clusterName(preview *devtoolsv1alpha1.Preview) string {
	return preview.Name + "-database"
}

func databaseConnectionEnv(cluster *cnpg.Cluster) []v1.EnvVar {
	secret := cluster.GetSuperuserSecretName()
	return []v1.EnvVar{
		{
			Name: "DB_USERNAME",
			ValueFrom: &v1.EnvVarSource{
				SecretKeyRef: &v1.SecretKeySelector{
					LocalObjectReference: v1.LocalObjectReference{
						Name: secret,
					},
					Key: "username",
				},
			},
		},
		{
			Name: "DB_PASSWORD",
			ValueFrom: &v1.EnvVarSource{
				SecretKeyRef: &v1.SecretKeySelector{
					LocalObjectReference: v1.LocalObjectReference{
						Name: secret,
					},
					Key: "password",
				},
			},
		},
		{
			Name:  "DB_DATABASE_NAME",
			Value: cluster.GetApplicationDatabaseName(),
		},
		{
			Name:  "DB_HOSTNAME",
			Value: cluster.GetServiceReadWriteName(),
		},
	}
}
