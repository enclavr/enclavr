const headerHTML = `
    <header class="header">
        <div class="container">
            <a href="index.html" class="logo">Enclavr</a>
            <nav class="nav">
                <a href="index.html">Home</a>
                <a href="overview.html">Docs</a>
                <a href="https://github.com/enclavr/enclavr" target="_blank">GitHub</a>
            </nav>
        </div>
    </header>
`;

const footerHTML = `
    <footer class="footer">
        <div class="container">
            <p>Copyright &copy; 2026 Enclavr.</p>
        </div>
    </footer>
`;

const sidebarData = {
    "Getting Started": [
        { label: "Introduction", href: "index.html" },
        { label: "Overview", href: "overview.html" },
        { label: "Architecture", href: "architecture.html" },
        { label: "Features", href: "features.html" }
    ],
    "Development": [
        { label: "Local Setup", href: "local-setup.html" },
        { label: "Commands", href: "commands.html" },
        { label: "Testing", href: "testing.html" }
    ],
    "API Reference": [
        { label: "Authentication", href: "authentication-api.html" },
        { label: "Rooms", href: "rooms-api.html" },
        { label: "Messages", href: "messages-api.html" },
        { label: "Direct Messages", href: "direct-messages-api.html" },
        { label: "Voice", href: "voice-api.html" },
        { label: "Admin", href: "admin-api.html" }
    ],
    "Frontend": [
        { label: "Overview", href: "frontend-overview.html" },
        { label: "Tech Stack", href: "frontend-tech-stack.html" },
        { label: "Components", href: "components.html" },
        { label: "State Management", href: "state-management.html" },
        { label: "API Client", href: "api-client.html" },
        { label: "WebRTC", href: "webrtc.html" }
    ],
    "Server": [
        { label: "Overview", href: "server-overview.html" },
        { label: "Tech Stack", href: "tech-stack.html" },
        { label: "Database Models", href: "database-models.html" },
        { label: "Authentication", href: "server-authentication.html" },
        { label: "WebSocket", href: "websocket.html" }
    ],
    "Infrastructure": [
        { label: "Overview", href: "infra-overview.html" },
        { label: "Services", href: "services.html" },
        { label: "Environment", href: "environment.html" },
        { label: "Deployment", href: "deployment.html" }
    ]
};

function getCurrentPage() {
    const path = window.location.pathname;
    const page = path.split('/').pop() || 'index.html';
    return page;
}

function injectSharedComponents() {
    const headerContainer = document.getElementById('header-content');
    const footerContainer = document.getElementById('footer-content');
    const sidebarContainer = document.getElementById('sidebar-content');

    if (headerContainer) headerContainer.innerHTML = headerHTML;
    if (footerContainer) footerContainer.innerHTML = footerHTML;

    if (sidebarContainer) {
        const currentPage = getCurrentPage();
        let html = '';
        for (const [sectionTitle, links] of Object.entries(sidebarData)) {
            html += `<div class="sidebar-section"><h3>${sectionTitle}</h3>`;
            for (const link of links) {
                const isActive = link.href === currentPage ? ' class="active"' : '';
                html += `<a href="${link.href}"${isActive}>${link.label}</a>`;
            }
            html += '</div>';
        }
        sidebarContainer.innerHTML = html;
    }
}

document.addEventListener('DOMContentLoaded', injectSharedComponents);
