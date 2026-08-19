<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>

<fmt:setLocale value="${currentResource.locale.language}" scope="session"/>

<c:set var="title" value="${currentNode.properties['jcr:title'].string}"/>
<c:set var="titleEscaped" value="${not empty title ? fn:escapeXml(title) : fn:escapeXml(currentNode.name)}"/>

<c:set var="teaser" value="${currentNode.properties['teaser'].string}"/>
<c:set var="body" value="${currentNode.properties['body'].string}"/>

<fmt:message key="label.date.at" var="at"/>
<c:set var="date" value="${currentNode.properties['date'].date}"/>
<fmt:formatDate value="${date.time}" pattern="dd MMM yyyy" var="formatedDate"/>
<fmt:formatDate value="${date.time}" pattern="HH:ss" var="formatedTime"/>
<c:if test="${not empty formatedDate && formatedTime != '00:00'}">
    <c:set var="formatedDate" value="${formatedDate} ${at} ${formatedTime}"/>
</c:if>

<c:set var="imageNode" value="${currentNode.properties['images'][0].node}"/>
<template:addCacheDependency node="${imageNode}"/>
<c:set var="width" value="${not empty currentResource.moduleParams.mediaWidth ? currentResource.moduleParams.mediaWidth : '1920'}"/>
<c:set var="height" value="${currentResource.moduleParams.mediaHeight}"/>
<c:set var="scale" value="${currentResource.moduleParams.mediaScale}"/>
<c:set var="quality" value="${currentResource.moduleParams.mediaQuality}"/>

<c:catch var ="getUrlException">
    <c:set var="imageURL" value="${imageNode.getUrl(['width:'.concat(width),'height:'.concat(height),'scale:'.concat(scale),'quality:'.concat(quality)])}"/>
</c:catch>
<c:if test = "${getUrlException != null}">
    <c:set var="imageURL" value="${imageNode.getUrl()}"/>
</c:if>

<c:set var="relatedDocs" value="${currentNode.properties['relatedDocs']}"/>

<div class="inner-page">
    <div class="slider-item" style="background-image: url('${imageURL}');">
    </div>
</div>

<section class="pb-5">
    <div class="container container-content bg-white">
        <div class="row justify-content-center">
            <div class="col-md-10 mb-5">
                <h1>${titleEscaped}</h1>
                <c:if test = "${not empty formatedDate}">
                <div class="border-top border-bottom border-secondary pt-4 pb-4">
                    <span class="ion-md-calendar mr-2"></span>
                    <fmt:message key="label.date.createdAt"/> : ${formatedDate}
                </div>
                </c:if>
            </div>
        </div>

        <div class="row row-teaser justify-content-center">
            <div class="col-md-10">
                <div class="lead">
                    ${teaser}
                </div>
            </div>
        </div>

        <div class="row row-article justify-content-center">
            <div class="col-md-10">
                ${body}
            </div>
        </div>
    </div>
    <c:if test="${not empty relatedDocs}">
    <div class="container industrial-pdf-viewer">
        <div class="row mt-5 p-5 ">
            <div class="col-12">
                <h2 style="margin-top: 2rem;"><fmt:message key="label.content.relatedDocs"/></h2>
            </div>
            <div class="col-lg-4">
                <div class="list-group" id="list-tab" role="tablist">
                    <c:forEach items="${relatedDocs}" var="relatedDoc" varStatus="status">
                        <c:set var="relatedDocNode" value="${relatedDoc.node}"/>
                        <template:addCacheDependency node="${relatedDocNode}"/>
                        <c:set var="title" value="${not empty relatedDocNode.properties['jcr:title'].string ? relatedDocNode.properties['jcr:title'].string : relatedDocNode.displayableName}" />
                        <c:set var="active" value="${status.first ? 'active' : ''}"/>
                        <a class="list-group-item list-group-item-action ${active}"
                           id="relatedDoc-list-${status.index}-list"
                           data-toggle="list"
                           href="#relatedDoc-list-${status.index}"
                           role="tab"
                           aria-controls="relatedDoc-list-${status.index}">
                                ${fn:escapeXml(title)}
                        </a>
                    </c:forEach>
                </div>
            </div>
            <div class="col-lg-8">
                <div class="tab-content" id="nav-tabContent">
                    <c:forEach items="${relatedDocs}" var="relatedDoc" varStatus="status">
                        <c:set var="relatedDocNode" value="${relatedDoc.node}"/>
                        <c:set var="active" value="${status.first ? 'active' : ''}"/>
                        <div class="tab-pane fade show ${active}" id="relatedDoc-list-${status.index}" role="tabpanel"
                             aria-labelledby="relatedDoc-list-${status.index}-list">
                            <iframe
                                    src="${relatedDocNode.getUrl()}"
                                    webkitallowfullscreen
                                    mozallowfullscreen
                                    allowfullscreen
                                    frameborder="0"
                                    allowtransparency="true"
                                    style="width:100%;min-height:500px">
                            </iframe>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
    </c:if>
</section>
