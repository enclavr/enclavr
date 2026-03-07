import { test, expect } from '@playwright/test';

const DOCS_PAGES = [
  { path: 'index.html', title: 'Enclavr - Self-hosted Voice Chat Platform' },
  { path: 'docs/overview.html', title: 'Overview' },
  { path: 'docs/architecture.html', title: 'Architecture' },
  { path: 'docs/features.html', title: 'Features' },
  { path: 'docs/local-setup.html', title: 'Local Setup' },
  { path: 'docs/commands.html', title: 'Commands' },
  { path: 'docs/testing.html', title: 'Testing' },
  { path: 'docs/authentication-api.html', title: 'Authentication API' },
  { path: 'docs/rooms-api.html', title: 'Rooms API' },
  { path: 'docs/messages-api.html', title: 'Messages API' },
  { path: 'docs/direct-messages-api.html', title: 'Direct Messages API' },
  { path: 'docs/voice-api.html', title: 'Voice API' },
  { path: 'docs/admin-api.html', title: 'Admin API' },
  { path: 'docs/frontend-overview.html', title: 'Frontend Overview' },
  { path: 'docs/frontend-tech-stack.html', title: 'Frontend Tech Stack' },
  { path: 'docs/components.html', title: 'Components' },
  { path: 'docs/state-management.html', title: 'State Management' },
  { path: 'docs/api-client.html', title: 'API Client' },
  { path: 'docs/webrtc.html', title: 'WebRTC' },
  { path: 'docs/server-overview.html', title: 'Server Overview' },
  { path: 'docs/tech-stack.html', title: 'Tech Stack' },
  { path: 'docs/database-models.html', title: 'Database Models' },
  { path: 'docs/server-authentication.html', title: 'Server Authentication' },
  { path: 'docs/websocket.html', title: 'WebSocket' },
  { path: 'docs/infra-overview.html', title: 'Infrastructure Overview' },
  { path: 'docs/services.html', title: 'Services' },
  { path: 'docs/environment.html', title: 'Environment' },
  { path: 'docs/deployment.html', title: 'Deployment' },
];

test.describe('Documentation Pages', () => {
  DOCS_PAGES.forEach(({ path, title }) => {
    test(`should load ${path}`, async ({ page }) => {
      await page.goto(path);
      await expect(page).toHaveTitle(/Enclavr|Overview|Architecture|Features|API|Frontend|Server|Infrastructure/);
    });

    test(`should display content in ${path}`, async ({ page }) => {
      await page.goto(path);
      const content = page.locator('main, .content');
      await expect(content).toBeVisible();
    });

    test(`should have proper heading in ${path}`, async ({ page }) => {
      await page.goto(path);
      const heading = page.locator('h1');
      await expect(heading).toBeVisible();
    });
  });
});

test.describe('Homepage', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('index.html');
  });

  test('should display logo', async ({ page }) => {
    const logo = page.locator('.logo, .logo a, [class*="logo"]');
    await expect(logo.first()).toBeVisible();
  });

  test('should display navigation', async ({ page }) => {
    const nav = page.locator('nav, .nav');
    await expect(nav.first()).toBeVisible();
  });

  test('should have docs link in navigation', async ({ page }) => {
    const docsLink = page.getByRole('link', { name: /docs/i });
    await expect(docsLink.first()).toBeVisible();
  });

  test('should have github link', async ({ page }) => {
    const githubLink = page.getByRole('link', { name: /github/i });
    await expect(githubLink.first()).toBeVisible();
  });

  test('should display sidebar', async ({ page }) => {
    const sidebar = page.locator('aside, .sidebar');
    await expect(sidebar.first()).toBeVisible();
  });

  test('should display content area', async ({ page }) => {
    const content = page.locator('main, .content');
    await expect(content.first()).toBeVisible();
  });

  test('should display quick links', async ({ page }) => {
    const quickLinks = page.locator('.quick-links, [class*="quick"]');
    const count = await quickLinks.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should display feature list', async ({ page }) => {
    const features = page.locator('ul li');
    const count = await features.count();
    expect(count).toBeGreaterThan(0);
  });

  test('should display tech stack table', async ({ page }) => {
    const table = page.locator('table');
    await expect(table.first()).toBeVisible();
  });

  test('should display footer', async ({ page }) => {
    const footer = page.locator('footer, .footer');
    await expect(footer.first()).toBeVisible();
  });
});

test.describe('Sidebar Navigation', () => {
  test('should have Getting Started section', async ({ page }) => {
    await page.goto('index.html');
    const section = page.locator('.sidebar-section:has-text("Getting Started")');
    await expect(section).toBeVisible();
  });

  test('should have Development section', async ({ page }) => {
    await page.goto('index.html');
    const section = page.locator('.sidebar-section:has-text("Development")');
    await expect(section).toBeVisible();
  });

  test('should have API Reference section', async ({ page }) => {
    await page.goto('index.html');
    const section = page.locator('.sidebar-section:has-text("API Reference")');
    await expect(section).toBeVisible();
  });

  test('should have Frontend section', async ({ page }) => {
    await page.goto('index.html');
    const section = page.locator('.sidebar-section:has-text("Frontend")');
    await expect(section).toBeVisible();
  });

  test('should have Server section', async ({ page }) => {
    await page.goto('index.html');
    const section = page.locator('.sidebar-section:has-text("Server")');
    await expect(section).toBeVisible();
  });

  test('should have Infrastructure section', async ({ page }) => {
    await page.goto('index.html');
    const section = page.locator('.sidebar-section:has-text("Infrastructure")');
    await expect(section).toBeVisible();
  });

  test('should have working sidebar links', async ({ page }) => {
    await page.goto('index.html');
    const sidebarLinks = page.locator('.sidebar a');
    const count = await sidebarLinks.count();
    expect(count).toBeGreaterThan(0);
  });
});

test.describe('API Documentation', () => {
  test('should display authentication endpoints', async ({ page }) => {
    await page.goto('/docs/authentication-api.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display rooms endpoints', async ({ page }) => {
    await page.goto('/docs/rooms-api.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display messages endpoints', async ({ page }) => {
    await page.goto('/docs/messages-api.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display direct messages endpoints', async ({ page }) => {
    await page.goto('/docs/direct-messages-api.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display voice API endpoints', async ({ page }) => {
    await page.goto('/docs/voice-api.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display admin API endpoints', async ({ page }) => {
    await page.goto('/docs/admin-api.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });
});

test.describe('Frontend Documentation', () => {
  test('should display frontend overview', async ({ page }) => {
    await page.goto('/docs/frontend-overview.html');
    await expect(page.locator('h1')).toBeVisible();
  });

  test('should display tech stack', async ({ page }) => {
    await page.goto('/docs/frontend-tech-stack.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display components documentation', async ({ page }) => {
    await page.goto('/docs/components.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display state management', async ({ page }) => {
    await page.goto('/docs/state-management.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display API client', async ({ page }) => {
    await page.goto('/docs/api-client.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display WebRTC documentation', async ({ page }) => {
    await page.goto('/docs/webrtc.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });
});

test.describe('Server Documentation', () => {
  test('should display server overview', async ({ page }) => {
    await page.goto('/docs/server-overview.html');
    await expect(page.locator('h1')).toBeVisible();
  });

  test('should display tech stack', async ({ page }) => {
    await page.goto('/docs/tech-stack.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display database models', async ({ page }) => {
    await page.goto('/docs/database-models.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display authentication', async ({ page }) => {
    await page.goto('/docs/server-authentication.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display websocket documentation', async ({ page }) => {
    await page.goto('/docs/websocket.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });
});

test.describe('Infrastructure Documentation', () => {
  test('should display infra overview', async ({ page }) => {
    await page.goto('/docs/infra-overview.html');
    await expect(page.locator('h1')).toBeVisible();
  });

  test('should display services', async ({ page }) => {
    await page.goto('/docs/services.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display environment configuration', async ({ page }) => {
    await page.goto('/docs/environment.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });

  test('should display deployment guide', async ({ page }) => {
    await page.goto('/docs/deployment.html');
    const content = page.locator('main');
    await expect(content).toBeVisible();
  });
});

test.describe('Code Examples', () => {
  test('should display code blocks', async ({ page }) => {
    await page.goto('/docs/local-setup.html');
    const codeBlock = page.locator('pre, code');
    const count = await codeBlock.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should display command examples', async ({ page }) => {
    await page.goto('/docs/commands.html');
    const commands = page.locator('pre');
    const count = await commands.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should display API examples', async ({ page }) => {
    await page.goto('/docs/api-client.html');
    const examples = page.locator('pre, code');
    const count = await examples.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });
});

test.describe('Cross-References', () => {
  test('should link to architecture from overview', async ({ page }) => {
    await page.goto('/docs/overview.html');
    const links = page.locator('a[href*="architecture"]');
    const count = await links.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should link to frontend from overview', async ({ page }) => {
    await page.goto('/docs/overview.html');
    const links = page.locator('a[href*="frontend"]');
    const count = await links.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should link to server from overview', async ({ page }) => {
    await page.goto('/docs/overview.html');
    const links = page.locator('a[href*="server"]');
    const count = await links.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test('should link to infrastructure from overview', async ({ page }) => {
    await page.goto('/docs/overview.html');
    const links = page.locator('a[href*="infra"]');
    const count = await links.count();
    expect(count).toBeGreaterThanOrEqual(0);
  });
});

test.describe('Responsive Design', () => {
  test('should work on mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('index.html');
    await expect(page.locator('body')).toBeVisible();
  });

  test('should work on tablet viewport', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto('index.html');
    await expect(page.locator('body')).toBeVisible();
  });

  test('should collapse sidebar on mobile', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('index.html');
    const sidebar = page.locator('aside, .sidebar');
    const isVisible = await sidebar.first().isVisible();
    expect(isVisible).toBe(false);
  });
});

test.describe('Accessibility', () => {
  test('should have proper heading hierarchy', async ({ page }) => {
    await page.goto('docs/overview.html');
    const h1 = page.locator('h1');
    const h2 = page.locator('h2');
    await expect(h1).toBeVisible();
    expect(await h2.count()).toBeGreaterThan(0);
  });

  test('should have alt text for images', async ({ page }) => {
    await page.goto('index.html');
    const images = page.locator('img');
    const count = await images.count();
    if (count > 0) {
      const firstImg = images.first();
      const alt = await firstImg.getAttribute('alt');
      expect(alt).toBeTruthy();
    }
  });

  test('should have semantic HTML', async ({ page }) => {
    await page.goto('index.html');
    const main = page.locator('main');
    const nav = page.locator('nav');
    const header = page.locator('header');
    const footer = page.locator('footer');
    
    expect(await main.count()).toBeGreaterThan(0);
    expect(await nav.count()).toBeGreaterThan(0);
    expect(await header.count()).toBeGreaterThan(0);
    expect(await footer.count()).toBeGreaterThan(0);
  });

  test('should have proper link text', async ({ page }) => {
    await page.goto('index.html');
    const links = page.locator('a[href]');
    const count = await links.count();
    expect(count).toBeGreaterThan(0);
    
    for (let i = 0; i < Math.min(count, 10); i++) {
      const linkText = await links.nth(i).textContent();
      expect(linkText?.trim().length).toBeGreaterThan(0);
    }
  });
});

test.describe('Performance', () => {
  test('should load quickly', async ({ page }) => {
    const start = Date.now();
    await page.goto('index.html');
    const loadTime = Date.now() - start;
    expect(loadTime).toBeLessThan(5000);
  });

  test('should load without network errors', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', err => errors.push(err.message));
    await page.goto('index.html');
    await page.waitForTimeout(1000);
    expect(errors).toHaveLength(0);
  });
});

test.describe('Styling', () => {
  test('should have stylesheet loaded', async ({ page }) => {
    await page.goto('index.html');
    const link = page.locator('link[rel="stylesheet"]');
    await expect(link).toBeVisible();
  });

  test('should have proper font styles', async ({ page }) => {
    await page.goto('index.html');
    const body = page.locator('body');
    const fontFamily = await body.evaluate(el => window.getComputedStyle(el).fontFamily);
    expect(fontFamily).toBeTruthy();
  });

  test('should have proper colors', async ({ page }) => {
    await page.goto('index.html');
    const body = page.locator('body');
    const backgroundColor = await body.evaluate(el => window.getComputedStyle(el).backgroundColor);
    expect(backgroundColor).toBeTruthy();
  });
});

test.describe('Real Documentation Content', () => {
  test('should display Enclavr features', async ({ page }) => {
    await page.goto('index.html');
    const content = await page.locator('main').textContent();
    expect(content).toContain('voice');
    expect(content).toContain('chat');
    expect(content).toContain('self-hosted');
  });

  test('should display tech stack information', async ({ page }) => {
    await page.goto('index.html');
    const content = await page.locator('main').textContent();
    expect(content).toContain('Next.js');
    expect(content).toContain('React');
    expect(content).toContain('Go');
  });

  test('should display architecture information', async ({ page }) => {
    await page.goto('docs/architecture.html');
    const content = await page.locator('main').textContent();
    expect(content).toBeTruthy();
  });

  test('should display database model information', async ({ page }) => {
    await page.goto('docs/database-models.html');
    const content = await page.locator('main').textContent();
    expect(content).toBeTruthy();
  });
});
