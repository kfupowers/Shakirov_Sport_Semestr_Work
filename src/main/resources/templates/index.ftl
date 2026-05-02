<#import "layout.ftl" as l>
<@l.page title="Главная">
    <div class="text-center">
        <h1 class="display-4">Спортивная платформа</h1>
        <p class="lead">Создавайте турниры, собирайте команды и соревнуйтесь!</p>
        <#if !user??>
            <a href="/register" class="btn btn-primary btn-lg">Присоединиться</a>
        </#if>
    </div>
    <div class="row mt-5">
        <div class="col-md-4">
            <h3><i class="bi bi-trophy"></i> Создайте турнир</h3>
            <p>Организуйте соревнования по футболу, теннису и другим видам спорта.</p>
        </div>
        <div class="col-md-4">
            <h3>Соберите команду</h3>
            <p>Добавляйте друзей в команду и регистрируйтесь на турниры.</p>
        </div>
        <div class="col-md-4">
            <h3>Следите за сеткой</h3>
            <p>Результаты матчей, плей-офф, итоговые места.</p>
        </div>
    </div>
</@l.page>