# Domain Reference

## Nameserver Mode

Use when Cloudflare manages DNS for the whole domain.

1. Add site/domain in Cloudflare.
2. Cloudflare shows two nameservers, for example:
   - `ace.ns.cloudflare.com`
   - `kami.ns.cloudflare.com`
3. In the registrar, replace existing nameservers with the Cloudflare nameservers.
4. Wait for Cloudflare activation.
5. Add custom domain under the Worker/Pages project.

Activation can take minutes to 24 hours. During that period, old and new DNS may both appear depending on resolver cache.

## Worker Custom Domain

Cloudflare dashboard path:

```text
Workers & Pages -> <worker> -> Domains -> Add custom domain
```

Add:

```text
example.com
www.example.com
```

Use the exact hostname the user wants public visitors to type.

## DNS Record Mode

Use if the domain stays outside Cloudflare DNS:

- Add a CNAME from `www` to the Worker/Pages target if supported.
- Apex/root domains may require Cloudflare DNS or registrar-specific ALIAS/ANAME support.

## Common Confusions

- Cloudflare Web Analytics "Add site" is not domain binding.
- ICP filing is separate from DNS. It may matter for mainland China hosting/compliance, but it does not block Cloudflare DNS activation by itself.
- Registrar "template transfer" or "domain ownership template" is not the same as DNS nameserver change.
- If a phone can open the workers.dev URL but a PC cannot, test DNS/network/firewall first; it is usually not a deployment issue.
