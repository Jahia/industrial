<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="imageNode" value="${currentNode.properties['image'].node}"/>
<c:if test="${not empty imageNode}">
    <template:addCacheDependency node="${imageNode}"/>
    <c:set var="alt" value="${fn:escapeXml(currentNode.displayableName)}"/>
    <c:set var="baseURL" value="${imageNode.getUrl()}"/>

    <%-- Candidate widths: imageWidths property, else module defaults --%>
    <c:set var="widthsCsv" value=""/>
    <c:forEach items="${currentNode.properties['imageWidths']}" var="w" varStatus="status">
        <c:set var="widthsCsv" value="${widthsCsv}${status.first ? '' : ','}${w.long}"/>
    </c:forEach>
    <c:if test="${empty widthsCsv}">
        <c:set var="widthsCsv" value="400,750,1024,1920"/>
    </c:if>
    <c:set var="widths" value="${fn:split(widthsCsv, ',')}"/>

    <%-- Fallback src width: defaultImageWidth property, else moduleParams, else 750 --%>
    <c:set var="defaultWidth" value="${currentNode.properties['defaultImageWidth'].long}"/>
    <c:if test="${empty defaultWidth}">
        <c:set var="defaultWidth" value="${not empty currentResource.moduleParams.mediaWidth ? currentResource.moduleParams.mediaWidth : '750'}"/>
    </c:if>
    <c:catch var="getUrlException">
        <c:set var="imageURL" value="${imageNode.getUrl(['w:'.concat(defaultWidth)])}"/>
    </c:catch>
    <c:if test="${getUrlException != null || empty imageURL}">
        <c:set var="imageURL" value="${baseURL}"/>
    </c:if>

    <c:set var="sizes" value="${not empty currentNode.properties['imageSizes'].string ? currentNode.properties['imageSizes'].string : currentResource.moduleParams.sizes}"/>
    <c:if test="${empty sizes}">
        <c:set var="sizes" value="100vw"/>
    </c:if>
    <c:set var="loading" value="${not empty currentResource.moduleParams.loading ? currentResource.moduleParams.loading : 'lazy'}"/>

    <c:set var="media" value="${currentNode.properties['imageMedia']}"/>
    <c:choose>
        <%-- Art direction: one <source> per media query, paired with the width at the same index --%>
        <c:when test="${not empty media}">
            <picture>
                <c:forEach items="${widths}" var="width" varStatus="status">
                    <c:if test="${not empty media[status.index]}">
                        <c:catch var="getUrlException">
                            <c:set var="currentImageURL" value="${imageNode.getUrl(['w:'.concat(width)])}"/>
                        </c:catch>
                        <c:if test="${getUrlException != null || empty currentImageURL}">
                            <c:set var="currentImageURL" value="${baseURL}"/>
                        </c:if>
                        <source media="${media[status.index].string}" srcset="${currentImageURL}">
                    </c:if>
                </c:forEach>
                <img width="100%"
                     src="${imageURL}"
                     class="${currentResource.moduleParams.class}"
                     loading="${loading}"
                     decoding="async"
                     alt="${alt}"
                />
            </picture>
        </c:when>
        <%-- Resolution switching: one srcset candidate per width, browser picks via sizes.
             Providers that don't support resize params return the plain URL: such
             candidates are skipped so we never emit a srcset of identical URLs. --%>
        <c:otherwise>
            <c:set var="srcset" value=""/>
            <c:forEach items="${widths}" var="width">
                <c:catch var="getUrlException">
                    <c:set var="currentImageURL" value="${imageNode.getUrl(['w:'.concat(width)])}"/>
                </c:catch>
                <c:if test="${getUrlException == null && not empty currentImageURL && currentImageURL != baseURL}">
                    <c:set var="srcset" value="${srcset}${empty srcset ? '' : ', '}${currentImageURL} ${width}w"/>
                </c:if>
            </c:forEach>
            <img width="100%"
                 src="${imageURL}"
                 <c:if test="${not empty srcset}">srcset="${srcset}" sizes="${sizes}"</c:if>
                 class="${currentResource.moduleParams.class}"
                 loading="${loading}"
                 decoding="async"
                 alt="${alt}"
            />
        </c:otherwise>
    </c:choose>
</c:if>
