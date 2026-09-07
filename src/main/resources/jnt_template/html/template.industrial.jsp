<!DOCTYPE html>
<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>

<%--Get custom css--%>
<jcr:sql
		var="_css_"
	 	sql="SELECT * FROM [jnt:file] As node WHERE ISDESCENDANTNODE (node, '${renderContext.site.path}/files/css')"
/>
<jcr:sql
		var="_css_content_"
		sql="SELECT * FROM [tint:css] As node WHERE ISDESCENDANTNODE (node, '${renderContext.site.path}/contents')"
/>
<%--Get custom script--%>
<jcr:sql
		var="_jsh_"
		sql="SELECT * FROM [jnt:file] As node WHERE ISDESCENDANTNODE (node, '${renderContext.site.path}/files/js/header')"
/>
<jcr:sql
		var="_jsf_"
		sql="SELECT * FROM [jnt:file] As node WHERE ISDESCENDANTNODE (node, '${renderContext.site.path}/files/js/footer')"
/>

<html lang="${fn:substring(renderContext.request.locale,0,2)}">
  <head>
    <title>${fn:escapeXml(renderContext.mainResource.node.displayableName)}</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

<%--  	<c:if test="${jcr:isNodeType(renderContext.mainResource.node, 'ogmix:openGraph')}">--%>
<%--		<template:module node="${renderContext.mainResource.node}" nodeTypes="ogmix:openGraph" />--%>
<%--	</c:if>--%>

    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,700|Oxygen:400,700" rel="stylesheet">
<%--    <link rel="stylesheet" href="/modules/industrial/css/ionicons.4.6.3.min.css" media="screen" type="text/css">--%>
	  	<%-- used by other module, load it now to be sure it will not be loaded later and overwrite style.css--%>

		<template:addResources type="css" resources="bootstrap.min.css" />

		<%-- come from animate module --%>
    	<template:addResources type="css" resources="animate.min.css" />

		<template:addResources type="css" resources="owl.carousel.min.css" />
		<template:addResources type="css" resources="jquery.fancybox.min.css" />
<%--		<template:addResources type="css" resources="ionicons.min.css" />--%>


		<template:addResources type="css" resources="font-awesome.min.css" />

		<!-- Theme Style -->
		<template:addResources type="css" resources="style.css" />
    	<template:addResources type="css" resources="style.patch.css" />
		<%-- Forms built with Formidable, on the module's class hooks --%>
    	<template:addResources type="css" resources="formidable.css" />

<%--	  position is important to be sure custom css will not merged with ofthers and is loaded at the end --%>
	  <template:addResources type="css" resources="ionicons.4.6.3.min.css" media="screen"/>

		<c:forEach items="${_css_.nodes}" var="node">
			<c:url var="customCSSUrl" value="${node.url}"/>
			<c:if test="${fn:endsWith(customCSSUrl, '.css')}">
				<template:addResources type="css" resources="${customCSSUrl}"/>
			</c:if>
		</c:forEach>

		<c:forEach items="${_css_content_.nodes}" var="node">
<%--			<utility:logger level="info" value=" ***** css : ${node.properties.text.string}"/>--%>
			<template:module node="${node}" nodeTypes="tint:css"/>
		</c:forEach>


		<c:if test="${renderContext.editMode}">
			<template:addResources type="css" resources="edit.css"/>
		</c:if>

	  <template:addResources type="javascript" resources="jquery.min.js,popper.min.js,bootstrap.min.js,owl.carousel.min.js"/>

	  	<c:forEach items="${_jsh_.nodes}" var="node">
			<c:url var="customJshUrl" value="${node.url}"/>
			<c:if test="${fn:endsWith(customJshUrl, '.js')}">
			  <template:addResources type="javascript" resources="${customJshUrl}" async=""/>
			</c:if>
	  	</c:forEach>

  </head>


	<body>
      	<template:area path="headercontent"/>
      	<div class="top-shadow ${renderContext.editMode?'edit':''}"></div>
      	<template:area path="pagecontent"/>
		<footer class="site-footer" role="contentinfo">
			<div class="container">
				<template:area path="footercontent"/>
				<div class="row">
					<div class="col-12 text-md-center text-left">
						<p class="copyright">
							<!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
							Copyright &copy;<script>document.write(new Date().getFullYear());</script> All rights reserved | This template is made with <i class="fa fa-heart text-danger" aria-hidden="true"></i> by <a href="https://colorlib.com" target="_blank" >Colorlib</a>
							<!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
						</p>
					</div>
				</div>
			</div>
		</footer>


<%--		<template:addResources type="javascript" resources="jquery-3.3.1.min.js" targetTag="body"/>--%>
<%--      	<template:addResources type="javascript" resources="popper.min.js" targetTag="body"/>--%>
<%--      	<template:addResources type="javascript" resources="bootstrap.min.js" targetTag="body"/>--%>
      	<%-- media="noAggregateAndCompress" --%>
<%--      	<template:addResources type="javascript" resources="owl.carousel.min.js" targetTag="body"/>--%>
<%--      	<template:addResources type="javascript" resources="jquery.waypoints.min.js" targetTag="body"/>--%>
		<template:addResources type="javascript" resources="jquery.appear.min.js" targetTag="body"/>
      	<template:addResources type="javascript" resources="jquery.fancybox.min.js" targetTag="body"/>
      	<template:addResources type="javascript" resources="main.js" targetTag="body"/>

		<c:forEach items="${_jsf_.nodes}" var="node">
			<c:url var="customJsfUrl" value="${node.url}"/>
			<c:if test="${fn:endsWith(customJsfUrl, '.js')}">
				<template:addResources type="javascript" resources="${customJsfUrl}" targetTag="body"/>
			</c:if>
		</c:forEach>
	</body>

</html>
