package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// PreviewSpec defines the desired state of Preview
type PreviewSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	// Foo is an example field of Preview. Edit preview_types.go to remove/update
	Foo string `json:"foo,omitempty"`
}

// PreviewStatus defines the observed state of Preview
type PreviewStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file
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
