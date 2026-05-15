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
                        searchResults.innerHTML = '';
                        if (data.length === 0) {
                            const noResults = document.createElement('div');
                            noResults.className = 'dropdown-item text-muted';
                            noResults.textContent = 'Ничего не найдено';
                            searchResults.appendChild(noResults);
                        } else {
                            data.forEach(comp => {
                                const link = document.createElement('a');
                                link.className = 'dropdown-item';
                                link.href = '/competitions/' + comp.id;
                                link.textContent = comp.title + ' (' + comp.disciplineName + ')';
                                searchResults.appendChild(link);
                            });
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
        if (!init.headers) {
            init.headers = {};
        }

        if (csrfToken && csrfHeader) {
            init.headers[csrfHeader] = csrfToken;
        }

        const method = (init.method || 'GET').toUpperCase();
        const hasBody = init.body !== undefined && init.body !== null;
        const needsContentType = hasBody && method !== 'GET' && method !== 'HEAD';

        if (needsContentType && !init.headers['Content-Type']) {
            if (init.body instanceof FormData) {
            } else {
                init.headers['Content-Type'] = 'application/x-www-form-urlencoded';
            }
        }

        return originalFetch.call(window, input, init);
    };
})();