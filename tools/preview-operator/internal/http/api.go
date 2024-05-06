package http

import (
	"encoding/json"
	"github.com/immich-app/devtools/tools/preview-operator/api/v1alpha1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"net/http"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"strings"
)

type PreviewApi struct {
	svc PreviewService
}

// TODO: Should this be more wrapped/not reuse the internal types?
type PreviewDTO struct {
	Name   string                 `json:"name"`
	Spec   v1alpha1.PreviewSpec   `json:"spec"`
	Status v1alpha1.PreviewStatus `json:"status"`
}

func Serve(c client.Client) error {
	svc := BuildPreviewService(c)
	handler := &PreviewApi{svc: svc}

	mux := http.NewServeMux()

	mux.HandleFunc("GET /api/preview/", handler.listPreviews)
	mux.HandleFunc("POST /api/preview", handler.createPreview)
	mux.HandleFunc("GET /api/preview/{name}", handler.getPreview)

	return http.ListenAndServe(":8088", mux)
}

func (previewApi *PreviewApi) listPreviews(w http.ResponseWriter, r *http.Request) {
	previews, err := previewApi.svc.ListPreviews(r.Context())
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	var resp []PreviewDTO
	for _, preview := range previews {
		resp = append(resp, PreviewDTO{
			Name:   preview.Name,
			Spec:   preview.Spec,
			Status: preview.Status,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	err = json.NewEncoder(w).Encode(resp)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func (previewApi *PreviewApi) getPreview(w http.ResponseWriter, r *http.Request) {
	name := r.PathValue("id")
	preview, err := previewApi.svc.GetPreview(r.Context(), name)
	if err != nil {
		if apierrors.IsNotFound(err) {
			http.Error(w, "preview not found", http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	err = json.NewEncoder(w).Encode(preview)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	return
}

func (previewApi *PreviewApi) createPreview(w http.ResponseWriter, r *http.Request) {
	request := previewCreateRequest{}
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	preview, err := previewApi.svc.CreatePreview(r.Context(), request)
	if err != nil {
		//Is this how you're supposed to handle errors? Cause this feels awful
		if preview != nil && strings.Contains(err.Error(), "preview already exists") {
			w.WriteHeader(http.StatusOK)
			w.Header().Set("Content-Type", "application/json")
			w.Header().Set("Location", "/api/preview/"+preview.Name)
			//TODO: Should we write a body? Anything else to wrap up the request?
			return
		}

		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response := PreviewDTO{
		Name:   preview.Name,
		Spec:   preview.Spec,
		Status: preview.Status,
	}

	w.WriteHeader(http.StatusCreated)
	w.Header().Set("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(response)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	//I think at this point we're done handling the request??
	//I have no idea whether I need to call something to wrap it up lol

}
