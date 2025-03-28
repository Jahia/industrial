<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<c:set var="targetNodePath" value="${renderContext.mainResource.node.path}"/>
<%--<c:if test="${!empty param.targetNodePath}">--%>
<%--    <c:set var="targetNodePath" value="${param.targetNodePath}"/>--%>
<%--</c:if>--%>
<%--<utility:logger level="info" value="***** targetNodePath default: ${targetNodePath} *****"/>--%>
<c:if test="${!empty currentNode.properties['j:target']}">
    <c:set var="target" value="${currentNode.properties['j:target'].string}"/>
</c:if>
<c:if test="${!empty currentNode.properties.folder}">
    <c:set var="targetNodePath" value="${currentNode.properties.folder.node.path}"/>
</c:if>
<jcr:node var="targetNode" path="${targetNodePath}"/>

<%--<utility:logger level="info" value="***** targetNodePath final: ${targetNodePath} *****"/>--%>
<div class="row mt-5 p-5 pdf-list-viewer">
    <div class="col-12">
        <h2>${currentNode.displayableName}</h2>
    </div>
<%--    <c:if test="${not empty targetNode.nodes}">--%>
        <div class="col-lg-4">
            <div class="list-group" id="list-tab" role="tablist">
                <c:forEach items="${targetNode.nodes}" var="subchild" varStatus="status">
<%--                    <utility:logger level="info" value="***** subchild : ${subchild.displayableName} *****"/>--%>
<%--                    <utility:logger level="info" value="***** test jnt:file : ${jcr:isNodeType(subchild, 'jnt:file')} *****"/>--%>
                    <c:if test="${jcr:isNodeType(subchild, 'jnt:file')}">
                        <%--            <c:forEach items="${relatedDocs}" var="relatedDoc" varStatus="status">--%>
                        <c:set var="relatedDocNode" value="${subchild}"/>
                        <c:set var="title" value="${not empty relatedDocNode.properties['jcr:title'] ? relatedDocNode.properties['jcr:title'] : relatedDocNode.displayableName}"/>

                        <template:addCacheDependency node="${relatedDocNode}"/>
                        <c:set var="active" value="${status.first ? 'active' : ''}"/>
                        <a class="list-group-item list-group-item-action ${active}"
                           id="relatedDoc-list-${status.index}-list"
                           data-toggle="list"
                           href="#relatedDoc-list-${status.index}"
                           role="tab"
                           aria-controls="related document ${status.index}">
                                ${fn:escapeXml(title)}
                        </a>
                    </c:if>
                </c:forEach>
            </div>
        </div>
        <div class="col-lg-8">
            <div class="tab-content" id="nav-tabContent">
                <c:forEach items="${targetNode.nodes}" var="subchild" varStatus="status">
                    <c:if test="${jcr:isNodeType(subchild, 'jnt:file')}">
                        <c:set var="relatedDocNode" value="${subchild}"/>
                        <c:set var="active" value="${status.first ? 'active' : ''}"/>
                        <div class="tab-pane fade show ${active}" id="relatedDoc-list-${status.index}" role="tabpanel"
                             aria-labelledby="relatedDoc-list-${status.index}-list">
                            <iframe
                                    src="${relatedDocNode.getUrl()}"
                                    webkitallowfullscreen
                                    mozallowfullscreen
                                    allowfullscreen
                                    frameborder="0"
                                    allowtransparency="true">
<%--                                    style="width:100%;min-height:700px">--%>
                            </iframe>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>
<%--    </c:if>--%>
</div>

<template:addCacheDependency path="${targetNodePath}"/>
