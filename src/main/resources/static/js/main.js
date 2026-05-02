(function() {
    const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
    const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;


    const searchInput = document.getElementById('searchInput');
    const searchResults = document.getElementById('searchResults');

    if (searchInput) {
        let debounceTimer;
        searchInput.addEventListener('input', function() {
            clearTimeout(debounceTimer);
            const query = this.value.trim();
            if (query.length < 2) {
                searchResults.style.display = 'none';
                searchResults.innerHTML = '';
                return;
            }
            debounceTimer = setTimeout(() => {
                fetch('/api/competitions?discipline=' + encodeURIComponent(query))
                    .then(response => {
                        if (!response.ok) throw new Error('Ошибка сети');
                        return response.json();
                    })
                    .then(data => {
                        if (data.length === 0) {
                            searchResults.innerHTML = '<div class="dropdown-item text-muted">Ничего не найдено</div>';
                        } else {
                            searchResults.innerHTML = data.map(comp =>
                                `<a class="dropdown-item" href="/competitions/${comp.id}">${comp.title} (${comp.disciplineName})</a>`
                            ).join('');
                        }
                        searchResults.style.display = 'block';
                    })
                    .catch(err => {
                        console.error(err);
                        searchResults.style.display = 'none';
                    });
            }, 300);
        });

        document.addEventListener('click', function(e) {
            if (!e.target.closest('#searchForm')) {
                searchResults.style.display = 'none';
            }
        });
    }

    const originalFetch = window.fetch;
    window.fetch = function(input, init = {}) {
        if (init.headers === undefined) {
            init.headers = {};
        }
        if (!(init.body instanceof FormData)) {
            init.headers['Content-Type'] = init.headers['Content-Type'] || 'application/x-www-form-urlencoded';
        }
        if (csrfToken && csrfHeader) {
            init.headers[csrfHeader] = csrfToken;
        }
        return originalFetch.call(window, input, init);
    };
})();