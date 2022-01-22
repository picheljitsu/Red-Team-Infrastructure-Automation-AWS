resource "aws_route53_zone" "redirector_zone" {
  name = "${var.domain-rdir}"
}

resource "aws_route53_zone" "c2_zone" {
  name = "${var.domain-rdir}"
}

# c2 redirector A #1
resource "aws_route53_record" "c2-http-rdr-a1" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}"
    name   = "${var.sub1}"
    records = ["${var.sub1}.${var.domain-rdir}"]
    type   = "A"    
    ttl    = 6020
}
# c2 redirector A #2
resource "aws_route53_record" "c2-http-rdr-a1" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}"
    name   = "${var.sub2}"
    records = ["${var.sub2}.${var.domain-rdir}"]
    type   = "A"    
    ttl    = 6020
}

# Cobaltstrike Backend C2 http A #2
resource "aws_route53_record" "c2-http-a1" {
    zone_id = "${aws_route53_zone.c2_zone.zone_id}"
    name   = "${var.sub3}"
    value  = "${aws_instance.c2-http.ipv4_address}"
    records = ["${var.sub3}.${var.domain-rdir}"]    
    type   = "A"
    ttl    = 6020
}
# Cobaltstrike Backend C2 http A #2
resource "aws_route53_record" "c2-http-a2" {
    zone_id = "${aws_route53_zone.c2_zone.zone_id}"
    name   = "${var.sub4}"
    value  = "${aws_instance.c2-http.ipv4_address}"
    records = ["${var.sub4}.${var.domain-rdir}"]    
    type   = "A"
    ttl    = 6020
}


# GoPhish email server
resource "aws_route53_record" "phishing-a1" {
    zone_id = "${aws_route53_zone.c2_zone.zone_id}"
    name   = "${var.sub6}"
    value  = "${aws_instance.phishing.ipv4_address}"
    type   = "A"
    ttl    = 120
}


# phishing redirector A #1
resource "aws_route53_record" "phishing-rdr-a0" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}"
    name   = "@"
    value  = "${aws_instance.phishing-rdr.ipv4_address}"
    type   = "A"
    ttl    = 60
}
# phishing redirector A #3
resource "aws_route53_record" "phishing-rdr-a1" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}"
    name   = "${var.sub6}"
    value  = "${aws_instance.phishing-rdr.ipv4_address}"
    type   = "A"
    ttl    = 60
}

# mail relay A
resource "aws_route53_record" "phishing-rdr-mail-a1" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}"
    name   = "mail"
    value  = "${aws_instance.phishing-rdr.ipv4_address}"
    type   = "A"
    ttl    = 60
}
# mail relay MX
resource "aws_route53_record" "phishing-rdr-mail-mx" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}"
    name   = "@"
    records  = ["mail.${var.domain-rdir}."]
    type   = "MX"
    priority = 5
    ttl    = 60
}
# mail relay TXT SPF
resource "aws_route53_record" "phishing-rdr-mail-spf" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}"
    name   = "@"
    records = ["v=spf1 ip4:${aws_instance.phishing-rdr.ipv4_address} include:_spf.google.com ~all"]
    type   = "TXT"
    ttl    = 60
}
# mail relay TXT DKIM placeholder
resource "aws_route53_record" "phishing-rdr-mail-dkim" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}" 
    name   = "mail._domainkey"
    records = ["I am DKIM, but change me with the DKIM provided by finalize.sh"]
    type   = "TXT"
    ttl    = 60
}
# mail relay TXT DMARC
resource "aws_route53_record" "phishing-rdr-mail-dmarc" {
    zone_id = "${aws_route53_zone.redirector_zone.zone_id}"
    name   = "_dmarc"
    records = ["v=DMARC1; p=reject"]
    type   = "TXT"
    ttl    = 60
}


