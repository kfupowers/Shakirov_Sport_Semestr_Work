<#macro page title="Спортивная платформа">
    <!DOCTYPE html>
    <html lang="ru">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${title}</title>
        <!-- Bootstrap 5 CSS (CDN для простоты, можно скачать) -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="/css/style.css" rel="stylesheet">
        <!-- CSRF-токен для всех AJAX-запросов -->
        <meta name="_csrf" content="${_csrf?if_exists.token}"/>
        <meta name="_csrf_header" content="${_csrf?if_exists.headerName}"/>
    </head>
    <body class="d-flex flex-column min-vh-100">
    <#include "header.ftl">
    <main class="container flex-grow-1 mt-4 mb-4">
        <#nested>   <#-- сюда вставляется содержимое конкретной страницы -->
    </main>
    <#include "footer.ftl">
    <!-- Bootstrap JS и Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/js/main.js"></script>
    </body>
    </html>
</#macro>