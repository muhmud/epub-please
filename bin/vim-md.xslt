<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="my-stuff" version="2.0">
  <xsl:output method="text" encoding="utf-8" standalone="yes" indent="yes"/>

  <xsl:function name="x:space">
    <xsl:param name="text"/>
    <xsl:param name="next"/>
    <xsl:variable name="space"><xsl:if test="not(matches($text, '^[^a-zA-Z0-9,.;]$')) and not(matches($next, '^[,)}\].][.]?$'))"><xsl:value-of select="' '"/></xsl:if></xsl:variable>
    <xsl:sequence select="$space"/>
  </xsl:function>

  <xsl:template match="word"><xsl:value-of select="normalize-space(translate(., '&#xa;', ' '))"/><xsl:choose>
  <xsl:when test=". = '1.' and not(count(../preceding-sibling::line) = 0)"><xsl:value-of select="'&#160;'"/></xsl:when>
  <xsl:otherwise><xsl:value-of select="x:space(., following-sibling::*[1])"/></xsl:otherwise></xsl:choose></xsl:template>
  <xsl:template match="url">&lt;<xsl:value-of select="normalize-space(word)"/>&gt;</xsl:template>
  <xsl:template match="taglink|optionlink|codespan">`<xsl:value-of select="normalize-space(translate(word, '&#xa;', ' '))"/>`<xsl:value-of select="x:space(word, following-sibling::*[1])"/></xsl:template>
  <xsl:template match="argument"><xsl:value-of select="translate(concat('`', ., '`'), ' ', '')"/><xsl:value-of select="x:space(., following-sibling::*[1])"/></xsl:template>
  <xsl:template match="tag"/>

  <xsl:template match="h1"># <xsl:apply-templates select="*"/></xsl:template>
  <xsl:template match="h2">## <xsl:apply-templates select="*"/></xsl:template>
  <xsl:template match="h3">### <xsl:apply-templates select="*"/></xsl:template>

  <xsl:template match="column_heading">**<xsl:value-of select="normalize-space(word[1])"/>**<xsl:value-of select="'&#xa;'"/></xsl:template>

  <xsl:template match="codeblock">
```<xsl:choose>
  <xsl:when test="language"><xsl:value-of select="language"/></xsl:when>
  <xsl:otherwise><xsl:value-of select="'&#xa;'"/></xsl:otherwise></xsl:choose>
<xsl:apply-templates select="code/line"/>
```
</xsl:template>

  <xsl:template match="line_li"> - <xsl:apply-templates select="*"/></xsl:template>

  <xsl:template match="line">
  <xsl:variable name="is-title"><xsl:if test="not(name(..) = 'line_li') and *[last()][name() = 'tag']">1</xsl:if></xsl:variable>
  <xsl:if test="*[not(name() = 'tag')]"><xsl:if test="not(count(preceding-sibling::line) = 0) and *[1][name() = 'argument']"><xsl:value-of select="'&#xa;'"/></xsl:if><xsl:if test="$is-title = '1'">
---
  ***</xsl:if><xsl:variable name="text"><xsl:apply-templates select="*"/></xsl:variable><xsl:choose>
  <xsl:when test="$is-title = '1'"><xsl:value-of select="normalize-space($text)"/></xsl:when>
  <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise></xsl:choose><xsl:if test="$is-title = '1'">***<xsl:if test="count(following-sibling::line) &gt;= 1"><xsl:value-of select="'&#xa;'"/></xsl:if></xsl:if><xsl:value-of select="'&#xa;'"/></xsl:if></xsl:template>

  <xsl:template match="code/line"><xsl:value-of select="translate(., '&#xa;', ' ')"/><xsl:value-of select="'&#xa;'"/></xsl:template>

  <xsl:function name="x:is-noise">
    <xsl:param name="text"/>
    <xsl:variable name="noise">
      <xsl:choose>
        <xsl:when test="matches($text, 'NVIM REFERENCE MANUAL')">1</xsl:when>
        <xsl:when test="matches($text, 'Type .*gO.* to see the table of contents')">1</xsl:when>
        <xsl:when test="matches($text, '%s*%*?[a-zA-Z]+%.txt%*?%s+N?[vV]im%s*$')">1</xsl:when>
        <xsl:when test="matches($text, '^%s*vim?%:.*ft=help')">1</xsl:when>
        <xsl:when test="matches($text, '^%s*vim?%:.*filetype=help')">1</xsl:when>
        <xsl:when test="matches($text, '[*&gt;]local%-additions[*&lt;]')">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$noise"/>
  </xsl:function>

  <xsl:template match="block">
      <xsl:variable name="text">
        <xsl:apply-templates select="*"/>
      </xsl:variable>
      <xsl:if test="x:is-noise($text) = 0">
        <xsl:value-of select="concat($text, '&#xa;')"/>
      </xsl:if>
  </xsl:template>

  <xsl:template match="/">
    <xsl:apply-templates select="/help_file/block[position() &gt; 1]"/>
  </xsl:template>
</xsl:stylesheet>
