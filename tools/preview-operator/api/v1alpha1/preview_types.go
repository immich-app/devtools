package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type ImmichConfiguration struct {
	Tag string `json:"tag"`
}

type DatabaseInitType string

const (
	DatabaseInitTypeEmpty DatabaseInitType = "empty"
)

type DatabaseConfiguration struct {
	// +kubebuilder:default:=empty
	// +kubebuilder:validation:Enum:=empty
	// +optional
	InitType DatabaseInitType `json:"initType,omitempty"`
}

// PreviewSpec defines the desired state of Preview
type PreviewSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	Immich *ImmichConfiguration `json:"immich"`

	Database *DatabaseConfiguration `json:"database,omitempty"`
}

// PreviewStatus defines the observed state of Preview
type PreviewStatus struct {
	Conditions []metav1.Condition `json:"conditions,omitempty" patchStrategy:"merge" patchMergeKey:"type" protobuf:"bytes,1,rep,name=conditions"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

// Preview is the Schema for the previews API
type Preview struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   PreviewSpec   `json:"spec,omitempty"`
	Status PreviewStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

// PreviewList contains a list of Preview
type PreviewList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []Preview `json:"items"`
}

func init() {
	SchemeBuilder.Register(&Preview{}, &PreviewList{})
}
