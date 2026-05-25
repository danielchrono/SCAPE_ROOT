$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Item .).FullName

Describe "SCAPE Menus Integrity" {
    $navPath = Join-Path $repoRoot "Data\Manifests\Navigation.psd1"
    $topoPath = Join-Path $repoRoot "Data\Manifests\Topology.psd1"
    
    It "Navigation manifest should exist" {
        $navPath | Should Exist
    }

    $rawNav = Invoke-Command -ScriptBlock ([scriptblock]::Create((Get-Content $navPath -Raw)))
    $navigation = if ($rawNav -is [array]) { $rawNav[0] } else { $rawNav }

    $rawTopo = Invoke-Command -ScriptBlock ([scriptblock]::Create((Get-Content $topoPath -Raw)))
    $topology = if ($rawTopo -is [array]) { $rawTopo[0] } else { $rawTopo }

    $allModules = @()
    foreach ($domain in $topology.Keys) {
        if ($domain -eq '__Meta__') { continue }
        $mods = $topology[$domain]
        if ($mods -is [array]) {
            foreach ($m in $mods) {
                $name = if ($m -is [hashtable]) { $m.Name } else { $m.Name }
                if ($name) { $allModules += $name }
            }
        }
        elseif ($mods -is [hashtable]) {
             $name = $mods.Name
             if ($name) { $allModules += $name }
        }
    }

    foreach ($menuKey in $navigation.Keys) {
        if ($menuKey -eq '__Meta__') { continue }
        
        Context "Menu: $menuKey" {
            $menu = $navigation[$menuKey]
            
            It "Should have a TitleKey" {
                $menu.TitleKey | Should Not BeNullOrEmpty
            }

            It "Should have Items" {
                $menu.Items | Should Not BeNullOrEmpty
            }

            foreach ($item in $menu.Items) {
                $itemId = $item.Id
                
                It "Item [$itemId] should have required fields" {
                    $item.Id | Should Not BeNullOrEmpty
                    $item.TitleKey | Should Not BeNullOrEmpty
                    $item.Action | Should Not BeNullOrEmpty
                }

                if ($item.Action -eq 'NAVIGATE') {
                    It "Item [$itemId] NAVIGATE target [$($item.Target)] should exist" {
                        $navigation.ContainsKey($item.Target) | Should Be $true
                    }
                }

                if ($item.Action -eq 'TRIGGER') {
                    $target = $item.Payload.Target
                    It "Item [$itemId] TRIGGER target [$target] should be a valid module" {
                        $allModules -contains $target | Should Be $true
                    }
                }
            }
        }
    }
}
