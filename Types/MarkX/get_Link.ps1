foreach ($aNode in $this.XML | Select-Xml //a) {
    if ($aNode.Node.href) {
        $aNode.Node
    }
}