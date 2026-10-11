#!/bin/bash
cd ~/IT24100808_CTF || exit 1
FLAG="NEXORA{d1g1t4l_f00tpr1nts_x7Q2}"
mkdir -p assets documents/internal

# ---------- STYLESHEET ----------
cat > style.css << 'EOF'
:root{--navy:#0b1f3a;--blue:#1d4ed8;--teal:#0ea5a4;--bg:#f4f7fb;--ink:#1e293b;--muted:#64748b;--line:#e2e8f0}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:-apple-system,"Segoe UI",Helvetica,Arial,sans-serif;background:var(--bg);color:var(--ink);line-height:1.6}
a{color:var(--blue);text-decoration:none}
a:hover{text-decoration:underline}
header{background:var(--navy);position:sticky;top:0;z-index:10;box-shadow:0 2px 8px rgba(0,0,0,.25)}
.bar{max-width:1100px;margin:0 auto;padding:14px 24px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px}
.logo{color:#fff;font-weight:800;font-size:22px;letter-spacing:1px}
.logo span{color:var(--teal)}
nav a{color:#cbd5e1;margin-left:20px;font-size:15px;padding-bottom:4px}
nav a:hover{color:#fff;text-decoration:none}
nav a.active{color:#fff;border-bottom:2px solid var(--teal)}
.hero{background:linear-gradient(135deg,var(--navy),#1e3a8a 60%,var(--teal));color:#fff;padding:80px 24px;text-align:center}
.hero h1{font-size:44px;margin-bottom:12px}
.hero p{max-width:640px;margin:0 auto;font-size:18px;color:#dbeafe}
.btn{display:inline-block;margin-top:26px;background:var(--teal);color:#fff;padding:12px 28px;border-radius:6px;font-weight:600}
.btn:hover{text-decoration:none;background:#0d9488}
.pagehead{background:var(--navy);color:#fff;padding:44px 24px}
.pagehead h1{max-width:1100px;margin:0 auto;font-size:34px}
.pagehead p{max-width:1100px;margin:6px auto 0;color:#93c5fd}
main{max-width:1100px;margin:0 auto;padding:40px 24px}
h2{margin:30px 0 14px;color:var(--navy)}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:20px}
.card{background:#fff;border:1px solid var(--line);border-radius:10px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,.05)}
.card h3{color:var(--navy);margin-bottom:8px}
.card .tag{display:inline-block;font-size:12px;background:#e0f2fe;color:#0369a1;padding:2px 10px;border-radius:20px;margin-bottom:10px}
.date{color:var(--muted);font-size:13px}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:16px;margin:20px 0}
.stat{background:#fff;border-radius:10px;padding:22px;text-align:center;border:1px solid var(--line)}
.stat b{display:block;font-size:30px;color:var(--blue)}
table{width:100%;border-collapse:collapse;background:#fff;border-radius:10px;overflow:hidden;border:1px solid var(--line)}
th{background:var(--navy);color:#fff;text-align:left;padding:12px 16px;font-size:14px}
td{padding:12px 16px;border-top:1px solid var(--line);font-size:15px}
.badge{font-size:12px;padding:3px 10px;border-radius:20px;font-weight:600}
.ok{background:#dcfce7;color:#166534}
.away{background:#fee2e2;color:#991b1b}
.soon{background:#fef9c3;color:#854d0e}
.note{background:#eff6ff;border-left:4px solid var(--blue);padding:14px 18px;border-radius:6px;margin:20px 0}
footer{background:var(--navy);color:#94a3b8;text-align:center;padding:26px 24px;font-size:13px;margin-top:40px}
footer b{color:#fff}
EOF

# ---------- PAGE BUILDER ----------
a(){ if [ "$active" = "$1" ]; then echo "<a class=\"active\" href=\"$1.html\">$2</a>"; else echo "<a href=\"$1.html\">$2</a>"; fi; }

page(){
  local file="$1" title="$2" active="$3"
  {
    cat << EOF
<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title | Nexora Technologies</title>
<link rel="icon" href="data:,">
<link rel="stylesheet" href="style.css">
</head><body>
<header><div class="bar">
<div class="logo">NEXORA<span>.</span></div>
<nav>
$(a index Home)
$(a about About)
$(a careers Careers)
$(a news News)
$(a directory Directory)
$(a technology Technology)
$(a documents Documents)
</nav></div></header>
EOF
    cat
    cat << 'EOF'
<footer><b>Nexora Technologies</b> &middot; Secure software and network solutions<br>
&copy; 2026 Nexora Technologies. Fictional organisation created for an educational CTF exercise.</footer>
</body></html>
EOF
  } > "$file"
}

# ---------- HOME ----------
page index.html "Home" index << 'EOF'
<section class="hero">
<h1>Secure by design.<br>Trusted by enterprise.</h1>
<p>Nexora Technologies builds secure internal platforms and network solutions for organisations that cannot afford downtime.</p>
<a class="btn" href="about.html">Learn about us</a>
</section>
<main>
<h2>What we do</h2>
<div class="grid">
<div class="card"><h3>Secure Platforms</h3><p>Employee portals, internal tools and web applications built with security first.</p></div>
<div class="card"><h3>Network Solutions</h3><p>Resilient, monitored infrastructure for hybrid and on-premise environments.</p></div>
<div class="card"><h3>Security Operations</h3><p>Continuous monitoring, incident response and staff awareness programmes.</p></div>
</div>
<h2>Latest news</h2>
<div class="grid">
<div class="card"><span class="tag">Security</span><h3>Security Awareness Bulletin, Q3</h3><p class="date">Published by the Security Team</p><p><a href="news.html">Read more</a></p></div>
<div class="card"><span class="tag">Company</span><h3>Annual staff meetup</h3><p class="date">Held last month at head office</p><p><a href="news.html">Read more</a></p></div>
</div>
</main>
EOF

# ---------- ABOUT ----------
page about.html "About" about << 'EOF'
<div class="pagehead"><h1>About Nexora</h1><p>Building secure systems since 2015</p></div>
<main>
<p>Founded in 2015, Nexora Technologies builds secure internal platforms for enterprise clients. Our teams combine software engineering, network design and security operations under one roof.</p>
<div class="stats">
<div class="stat"><b>2015</b>Founded</div>
<div class="stat"><b>120+</b>Staff</div>
<div class="stat"><b>40+</b>Enterprise clients</div>
<div class="stat"><b>24/7</b>Monitoring</div>
</div>
<h2>Leadership</h2>
<div class="grid">
<div class="card"><h3>Security Team</h3><p>Our security team is led by <b>Alex Morgan</b>, responsible for monitoring, access control and incident response.</p></div>
<div class="card"><h3>Engineering</h3><p>Backend, web and network engineers delivering our client platforms.</p></div>
</div>
</main>
EOF

# ---------- CAREERS ----------
page careers.html "Careers" careers << 'EOF'
<div class="pagehead"><h1>Careers</h1><p>Join a team that takes security seriously</p></div>
<main>
<h2>Open roles</h2>
<div class="grid">
<div class="card"><span class="tag">Security</span><h3>Junior Penetration Tester</h3><p>Test our internal systems and help harden them.</p></div>
<div class="card"><span class="tag">Infrastructure</span><h3>Network Engineer</h3><p>Maintain and monitor our core network.</p></div>
<div class="card"><span class="tag">Engineering</span><h3>Backend Developer</h3><p>Build and maintain internal web platforms.</p></div>
</div>
<div class="note">Note: our Security Analyst position is temporarily unfilled.</div>
</main>
EOF

# ---------- NEWS ----------
page news.html "News" news << 'EOF'
<div class="pagehead"><h1>News</h1><p>Updates from across Nexora</p></div>
<main>
<div class="card"><span class="tag">Security</span><h3>Security Awareness Bulletin, Q3</h3>
<p class="date">Prepared by Alex Morgan, Security Analyst</p>
<p>The Q3 security bulletin has been prepared. It is restricted to internal staff and filed in our internal documents area.</p></div>
<br>
<div class="card"><span class="tag">Company</span><h3>Annual staff meetup</h3>
<p class="date">Held last month</p>
<p>Teams from every department gathered at head office for talks, workshops and dinner.</p></div>
</main>
EOF

# ---------- DIRECTORY ----------
page directory.html "Employee Directory" directory << 'EOF'
<div class="pagehead"><h1>Employee Directory</h1><p>Find your colleagues</p></div>
<main>
<table>
<tr><th>Name</th><th>Role</th><th>Department</th><th>Status</th></tr>
<tr><td>Alex Morgan</td><td>Security Analyst</td><td>Security</td><td><span class="badge away">Currently unavailable</span></td></tr>
<tr><td>Sam Perera</td><td>Network Engineer</td><td>Infrastructure</td><td><span class="badge ok">Available</span></td></tr>
<tr><td>Nadia Silva</td><td>Backend Developer</td><td>Engineering</td><td><span class="badge ok">Available</span></td></tr>
<tr><td>Ravi Jayasuriya</td><td>HR Manager</td><td>People</td><td><span class="badge ok">Available</span></td></tr>
</table>
</main>
EOF

# ---------- TECHNOLOGY ----------
page technology.html "Technology" technology << 'EOF'
<div class="pagehead"><h1>Our Technology</h1><p>The stack behind our platforms</p></div>
<main>
<div class="grid">
<div class="card"><h3>Web</h3><p>Python / Flask applications.</p></div>
<div class="card"><h3>Data</h3><p>SQLite databases for internal tools.</p></div>
<div class="card"><h3>Hosting</h3><p>Linux servers on a segmented internal network.</p></div>
</div>
<h2>Document management</h2>
<div class="note">Internal documents are stored under <b>/documents/</b> and named by type, for example <b>security_bulletin.txt</b>.</div>
</main>
EOF

# ---------- DOCUMENTS ----------
page documents.html "Documents" documents << 'EOF'
<div class="pagehead"><h1>Public Documents</h1><p>Resources available to visitors</p></div>
<main>
<table>
<tr><th>Document</th><th>Type</th><th>Status</th></tr>
<tr><td>Company brochure</td><td>PDF</td><td><span class="badge soon">Coming soon</span></td></tr>
<tr><td>Code of conduct</td><td>PDF</td><td><span class="badge soon">Coming soon</span></td></tr>
</table>
<div class="note">Internal documents are not listed here.</div>
</main>
EOF

# ---------- CLUE FILES ----------
printf 'User-agent: *\nDisallow: /documents/internal/\n' > robots.txt

cat > documents/internal/security_bulletin.txt << EOF
NEXORA SECURITY BULLETIN - CONFIDENTIAL
Author: Alex Morgan
Flag: $FLAG
Last upload: /assets/nexora_image.jpg
EOF

echo "ST-01 site built."
ls -F
