package gqlmodel

import (
	"github.com/reearth/reearth-cms/server/internal/usecase/interfaces"
	"github.com/reearth/reearth-cms/server/pkg/thread"
	"github.com/samber/lo"
)

func ToThread(th *thread.Thread) *Thread {
	if th == nil {
		return nil
	}

	return &Thread{
		ID:          IDFrom(th.ID()),
		WorkspaceID: IDFrom(th.Workspace()),
		Comments:    lo.Map(th.Comments(), func(c *thread.Comment, _ int) *Comment { return ToComment(c, th) }),
	}
}

func ToComment(c *thread.Comment, th *thread.Thread) *Comment {
	if c == nil {
		return nil
	}

	var authorID ID
	var authorType OperatorType
	if c.Author().User() != nil {
		authorID = IDFrom(*c.Author().User())
		authorType = OperatorTypeUser
	}
	if c.Author().Integration() != nil {
		authorID = IDFrom(*c.Author().Integration())
		authorType = OperatorTypeIntegration
	}

	return &Comment{
		ID:          IDFrom(c.ID()),
		ThreadID:    IDFrom(th.ID()),
		WorkspaceID: IDFrom(th.Workspace()),
		AuthorID:    authorID,
		AuthorType:  authorType,
		Content:     c.Content(),
		CreatedAt:   c.CreatedAt(),
	}
}

func FromResourceType(p ResourceType) (interfaces.ResourceType, bool) {
	var p2 interfaces.ResourceType
	switch p {
	case ResourceTypeItem:
		p2 = interfaces.ResourceTypeItem
	case ResourceTypeAsset:
		p2 = interfaces.ResourceTypeAsset
	case ResourceTypeRequest:
		p2 = interfaces.ResourceTypeRequest
	default:
		return "", false
	}

	return p2, true
}
