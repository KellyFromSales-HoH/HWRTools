namespace Upgrademe
{
    Upgrades::UpgradeShop@ m_shop;
    array<array<Upgrades::RecordUpgradeStep@>> m_tiers;


    [Hook]
    void GameModeConstructor(Campaign@ campaign)
    {
        AddFunction("k_skills", UnlockSkills);
        AddFunction("k_blacksmith", UnlockBlacksmithUpgrades);
        AddFunction("k_magic", UnlockMagicUpgrades);
        AddFunction("k_potion", UnlockPotionUpgrades);
        AddFunction("k_town_buildings", UnlockTownBuildings);

        AddFunction("k_flags", Flags);
        AddFunction("k_blueprints", GiveBlueprints);
        AddFunction("k_attunements", AttuneBlueprints);
        AddFunction("k_remove_blueprints", ResetBlueprints);

        AddFunction("k_town", UnlockTownUpgrades);
        AddFunction("k_char", UnlockAllCharacterUpgrades);

        AddFunction("k_reset_char", ResetUpgrades);
        AddFunction("k_reset_town", ResetTown);
        AddFunction("refresh", Refresh); // reloads so upgrades show, unlock all does it automatically


    }

    bool BuyItem(Upgrades::Upgrade@ upgrade, Upgrades::UpgradeStep@ step)
    {
        auto record = GetLocalPlayerRecord();
        auto player = GetLocalPlayer();
        OwnedUpgrade@ ownedUpgrade = record.GetOwnedUpgrade(upgrade.m_id);

        @ownedUpgrade = OwnedUpgrade();
        ownedUpgrade.m_id = upgrade.m_id;
        ownedUpgrade.m_idHash = upgrade.m_idHash;
        ownedUpgrade.m_level = step.m_level;
        @ownedUpgrade.m_step = step;
        record.upgrades.insertLast(ownedUpgrade);

        step.ApplyNow(record);

        (Network::Message("PlayerGiveUpgrade") << upgrade.m_id << step.m_level).SendToAll();

        return true;
    }

    void Refresh()
    {
        ChangeLevel(GetCurrentLevelFilename());
    }

    void UnlockSkills() //skills
    {
        auto record = GetLocalPlayerRecord();
        auto player = GetLocalPlayer();

        int m_numTiers = 5;
        @m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("trainer"));

        for (int i = 0; i < m_numTiers; i++)
            m_tiers.insertLast(array<Upgrades::RecordUpgradeStep@>());

        for (uint i = 0; i < m_shop.m_upgrades.length(); i++)
        {
            auto upgrade = m_shop.m_upgrades[i];
            auto steps = m_shop.m_upgrades[i].m_steps.length();

            for(uint o = 0; o < steps; o++)
            {
                if(upgrade.GetNextStep(record) != null)
                    BuyItem(upgrade, upgrade.GetNextStep(record));
            }
        }
    }

    void UnlockBlacksmithUpgrades() //blackmsith
    {
        auto record = GetLocalPlayerRecord();
        @m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("blacksmith"));

        for (uint i = 0; i < m_shop.m_upgrades.length(); i++)
        {
            auto upgrade = m_shop.m_upgrades[i];
            auto steps = m_shop.m_upgrades[i].m_steps.length();

            for(uint o = 0; o < steps; o++)
            {
                if(upgrade.GetNextStep(record) != null)
                    BuyItem(upgrade, upgrade.GetNextStep(record));
            }
        }
    }

    void UnlockMagicUpgrades() //magicshop
    {
        auto record = GetLocalPlayerRecord();
        @m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("magicshop"));

        for (uint i = 0; i < m_shop.m_upgrades.length(); i++)
        {
            auto upgrade = m_shop.m_upgrades[i];
            auto steps = m_shop.m_upgrades[i].m_steps.length();

            for(uint o = 0; o < steps; o++)
            {
                if(upgrade.GetNextStep(record) != null)
                    BuyItem(upgrade, upgrade.GetNextStep(record));
            }
        }
    }

    void UnlockPotionUpgrades() //apothecary
    {
        auto record = GetLocalPlayerRecord();
        @m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("apothecary"));

        for (uint i = 0; i < m_shop.m_upgrades.length(); i++)
        {
            auto upgrade = m_shop.m_upgrades[i];
            auto steps = m_shop.m_upgrades[i].m_steps.length();

            for(uint o = 0; o < steps; o++)
            {
                if(upgrade.GetNextStep(record) != null)
                    BuyItem(upgrade, upgrade.GetNextStep(record));
            }
        }
    }

    void UnlockAllCharacterUpgrades()
    {


        UnlockPotionUpgrades();
        UnlockMagicUpgrades();
        UnlockBlacksmithUpgrades();
        UnlockSkills();
        AttuneBlueprints();
        Refresh();
    }

    void UnlockTownUpgrades()
    {
        Flags();
        GiveBlueprints();
        UnlockTownBuildings();
    }

    void Flags()
    {
        g_flags.Set("special_ore", FlagState::Town);
        g_flags.Set("unlock_apothecary", FlagState::Town);
        g_flags.Set("unlock_thief", FlagState::Town);
        g_flags.Set("unlock_combo", FlagState::Town);
        g_flags.Set("unlock_magicshop", FlagState::Town);
        g_flags.Set("unlock_anvil", FlagState::Town);
        g_flags.Set("unlock_gladiator", FlagState::Town);
    }

    void ResetBlueprints()
    {
        auto gmCampaign = cast<Campaign>(g_gameMode);
        auto player = GetLocalPlayer();

        gmCampaign.m_townLocal.m_forgeBlueprints.removeRange(0, gmCampaign.m_townLocal.m_forgeBlueprints.length());
        player.m_record.itemForgeAttuned.removeRange(0, player.m_record.itemForgeAttuned.length());
    }

    void GiveBlueprints()
    {
            TownRecord@ town = null;
            auto gmMenu = cast<MainMenu>(g_gameMode);
            auto gmCampaign = cast<Campaign>(g_gameMode);
            auto player = GetLocalPlayer();

            player.m_record.itemForgeAttuned.removeRange(0, player.m_record.itemForgeAttuned.length());
            gmCampaign.m_townLocal.m_forgeBlueprints.removeRange(0, gmCampaign.m_townLocal.m_forgeBlueprints.length());

            if (gmMenu !is null)
                @town = gmMenu.m_town;
            else if (gmCampaign !is null)
                @town = gmCampaign.m_town;

            for (uint i = 0; i < g_items.m_allItemsList.length(); i++)
            {
                auto item = g_items.m_allItemsList[i];

                if (item.quality != ActorItemQuality::Epic && item.quality != ActorItemQuality::Legendary && item.hasBlueprints)
                {
                    if (!item.canAttune)
                    {
                        GiveForgeBlueprintImpl(item, GetLocalPlayer(), true);
                    }
                    else
                    {
                        GiveForgeBlueprintImpl(item, GetLocalPlayer(), true);
                    }
                }
            }
    }


    void AttuneBlueprints()
    {
        TownRecord@ town = null;
        auto gmMenu = cast<MainMenu>(g_gameMode);
        auto gmCampaign = cast<Campaign>(g_gameMode);
        auto player = GetLocalPlayer();

        if (gmMenu !is null)
            @town = gmMenu.m_town;
        else if (gmCampaign !is null)
            @town = gmCampaign.m_town;

        for (uint i = 0; i < town.m_forgeBlueprints.length(); i++)
        {
            auto item = g_items.GetItem(town.m_forgeBlueprints[i]);
            if (item.quality != ActorItemQuality::Epic && item.quality != ActorItemQuality::Legendary && item.hasBlueprints)
            {
                if (!item.canAttune)
                {
                    continue;
                }
                else
                {
                player.AttuneItem(item);
                }
            }
        }
    }

    void GiveAndAttuneBlueprints()
    {
        TownRecord@ town = null;
        auto gmMenu = cast<MainMenu>(g_gameMode);
        auto gmCampaign = cast<Campaign>(g_gameMode);
        auto player = GetLocalPlayer();

        player.m_record.itemForgeAttuned.removeRange(0, player.m_record.itemForgeAttuned.length());
        gmCampaign.m_townLocal.m_forgeBlueprints.removeRange(0, gmCampaign.m_townLocal.m_forgeBlueprints.length());

        if (gmMenu !is null)
            @town = gmMenu.m_town;
        else if (gmCampaign !is null)
            @town = gmCampaign.m_town;

        for (uint i = 0; i < g_items.m_allItemsList.length(); i++)
        {
            auto item = g_items.m_allItemsList[i];;
            if (item.quality != ActorItemQuality::Epic && item.quality != ActorItemQuality::Legendary && item.hasBlueprints)
            {
                if (!item.canAttune)
                {
                    GiveForgeBlueprintImpl(item, GetLocalPlayer(), true);
                }
                else
                {
                    GiveForgeBlueprintImpl(item, GetLocalPlayer(), true);
                    player.AttuneItem(item);
                }
            }
        }
    }

    void ResetUpgrades()
    {
        auto record = GetLocalPlayerRecord();
        auto gm = cast<Campaign>(g_gameMode);
        auto town = gm.m_townLocal;

        record.upgrades.removeRange(0, record.upgrades.length());
        ChangeLevel(GetCurrentLevelFilename());
    }

    void ResetTown()
    {
        auto gm = cast<Campaign>(g_gameMode);
        auto town = gm.m_townLocal;

        town.m_buildings.removeRange(0, town.m_buildings.length());
        ChangeLevel(GetCurrentLevelFilename());
    }

    void UnlockTownBuildings() //townhall
    {
        auto record = GetLocalPlayerRecord();

        array<array<Upgrades::BuildingUpgradeStep@>> m_buildingtiers;
        array<Upgrades::BuildingUpgradeStep@> m_tiersTownhall;

        int m_numTiers = 6;
        int m_numUpgrades = 10;

        @m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("townhall"));

        for (int i = 0; i < m_numTiers; i++)
            m_buildingtiers.insertLast(array<Upgrades::BuildingUpgradeStep@>());

        for(int k = 0; k < m_shop.m_upgrades.length(); k++)
        {

            auto upgrade = m_shop.m_upgrades[k];
            auto steps = m_shop.m_upgrades[k].m_steps.length();

            for(uint o = 0; o < steps; o++)
            {
                if(upgrade.GetNextStep(record) != null){
                    auto upgradeStep = upgrade.GetNextStep(record);

                    // Some debugging
                    //print("BUYING: " + upgrade.m_id + " step: " + o + " IsOwned: " + upgrade.IsOwned(record));

                    upgradeStep.BuyNow(record);
                    upgradeStep.ApplyNow(record);
                }
            }
        }

            // Some debugging
            //for (uint i = 0; i < m_shop.m_upgrades.length(); i++)
            //{
            //    print(m_shop.m_upgrades[i].m_id);
            //}

            ChangeLevel(GetCurrentLevelFilename());
    }
}