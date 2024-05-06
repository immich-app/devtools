package http

import (
	"context"
	"errors"
	"github.com/immich-app/devtools/tools/preview-operator/api/v1alpha1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

// TODO: Should this be configurable somewhere?
const previewsNamespace = "preview"

type PreviewService struct {
	client client.Client
}

type previewCreateRequest struct {
	Name string               `json:"name"`
	Spec v1alpha1.PreviewSpec `json:"spec"`
}

func BuildPreviewService(c client.Client) PreviewService {
	return PreviewService{client: c}
}

// I totally just let the AI write this whole thing for me. No clue if it works :)
func (svc *PreviewService) ListPreviews(ctx context.Context) ([]v1alpha1.Preview, error) {
	log := log.FromContext(ctx)

	previewList := &v1alpha1.PreviewList{}
	err := svc.client.List(ctx, previewList, client.InNamespace(previewsNamespace))
	if err != nil {
		log.Error(err, "Error listing Previews")
		return nil, err
	}
	return previewList.Items, nil
}

func (svc *PreviewService) GetPreview(ctx context.Context, name string) (*v1alpha1.Preview, error) {
	log := log.FromContext(ctx)

	log.Info("Handling preview get request", "Preview Name", name)

	preview := v1alpha1.Preview{}
	err := svc.client.Get(ctx, types.NamespacedName{Name: name, Namespace: previewsNamespace}, &preview)
	if err != nil && apierrors.IsNotFound(err) {
		log.Error(err, "Preview not found")
		return nil, err
	} else if err != nil {
		log.Error(err, "Error getting preview")
		return nil, err
	}

	return &preview, nil
}

func (svc *PreviewService) CreatePreview(ctx context.Context, request previewCreateRequest) (*v1alpha1.Preview, error) {
	log := log.FromContext(ctx)

	name := request.Name

	log.Info("Handling preview create request", "Preview Name", request.Name)

	preview, err := svc.GetPreview(ctx, name)
	if err != nil && apierrors.IsNotFound(err) {
		pvw := v1alpha1.Preview{
			ObjectMeta: v1.ObjectMeta{
				Name:      request.Name,
				Namespace: previewsNamespace,
			},
			Spec: request.Spec,
		}

		err := svc.client.Create(ctx, &pvw)
		if err != nil {
			log.Error(err, "Failed to create preview")
			return nil, err
		}

		log.Info("Created preview", "Name", pvw.Name)
		return &pvw, nil
	} else if err != nil {
		log.Error(err, "Failed to get preview")
		return nil, err
	}

	return preview, errors.New("preview already exists")
}
