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
        AddFunction("k_drinks", UnlockTavernDrinks);
        AddFunction("k_chapel", UnlockChapel);
        AddFunction("k_town", UnlockTownUpgrades);
        AddFunction("k_char", UnlockAllCharacterUpgrades);
        AddFunction("k_reset_char", ResetUpgrades);
        AddFunction("k_reset_town", ResetTown);
        AddFunction("refresh", Refresh); // reloads so upgrades show, unlock all does it automatically
        AddFunction("k_all", UnlockAll);

        AddFunction("give_blueprints", {cvar_type::Int }, GiveRandomBlueprintsCfunc);
        AddFunction("give_blood_rite", { cvar_type::String, cvar_type::Int }, GiveBloodAltarCfunc);
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

    void UpgradeFunc(string shopName){
        // Debugging purposes
        //print("------ SHOP: " + shopName);
        @m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop(shopName));

        auto record = GetLocalPlayerRecord();
        auto player = GetLocalPlayer();

        for (uint i = 0; i < m_shop.m_upgrades.length(); i++)
        {
            auto upgrade = m_shop.m_upgrades[i];
            auto steps = m_shop.m_upgrades[i].m_steps.length();

            for(uint o = 0; o < steps; o++)
            {
                auto upgradeNextStep = upgrade.GetNextStep(record);
                if(upgradeNextStep != null)
                {
                    // Debugging purposes
                    // print("BUYING: " + upgrade.m_id + " step: " + o);

                if(shopName != "townhall")
                    {
                        BuyItem(upgrade, upgradeNextStep);
                    }
                    else
                    {
                        upgradeNextStep.BuyNow(record);
                    }
                }

            }
        }
    }

    void Refresh()
    {
        ChangeLevel(GetCurrentLevelFilename());
    }

    void UnlockSkills()
    {
        UpgradeFunc("trainer");
    }

    void UnlockBlacksmithUpgrades()
    {
        UpgradeFunc("blacksmith");
    }

    void UnlockMagicUpgrades()
    {
        UpgradeFunc("magicshop");
    }

    void UnlockPotionUpgrades()
    {
        UpgradeFunc("apothecary");
    }

    void UnlockTownBuildings()
    {
        UpgradeFunc("townhall");
    }

    void UnlockTavernDrinks()
    {
        auto player = GetLocalPlayer();

        for (uint i = 0; i < g_tavernDrinks.length(); i++)
        {
            auto drink = g_tavernDrinks[i];
            GiveTavernBarrelImpl(drink, player, false);
        }
    }

    void UnlockChapel()
    {
        auto record = GetLocalPlayerRecord();

        @m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("chapel"));

        for(uint i = 0; i < m_shop.m_upgrades.length(); i++)
        {
            record.chapelUpgradesPurchased.insertLast(m_shop.m_upgrades[i].m_id);
        }
    }

    void UnlockAll()
    {
        Flags();
        UnlockPotionUpgrades();
        UnlockMagicUpgrades();
        UnlockBlacksmithUpgrades();
        UnlockSkills();
        GiveBlueprints();
        AttuneBlueprints();
        UnlockTownBuildings();
        UnlockTavernDrinks();
        UnlockChapel();
        Refresh();
    }

    void UnlockAllCharacterUpgrades()
    {
        UnlockPotionUpgrades();
        UnlockMagicUpgrades();
        UnlockBlacksmithUpgrades();
        UnlockSkills();
        AttuneBlueprints();
        UnlockChapel();
        Refresh();
    }

    void UnlockTownUpgrades()
    {
        Flags();
        GiveBlueprints();
        UnlockTownBuildings();
        UnlockTavernDrinks();
        Refresh();
    }

    void Flags()
    {
        g_flags.Set("special_ore", FlagState::Town);
        g_flags.Set("unlock_apothecary", FlagState::Town);
        g_flags.Set("unlock_thief", FlagState::Town);
        g_flags.Set("unlock_combo", FlagState::Town);
        g_flags.Set("unlock_magicshop", FlagState::Town);
        g_flags.Set("unlock_anvil", FlagState::Town);
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
                GiveForgeBlueprintImpl(item, player, false);
            }
        }
    }

    ActorItem@ RandomBlueprintPicker()
    {
        auto gm = cast<Campaign>(g_gameMode);
        array<ActorItem@> possibleBlueprintItems;

        for (uint i = 0; i < g_items.m_allItemsList.length(); i++)
        {
            auto item = g_items.m_allItemsList[i];

            if (!item.hasBlueprints)
                continue;

            if (gm.m_townLocal.m_forgeBlueprints.find(item.idHash) != -1)
                continue;

            possibleBlueprintItems.insertLast(item);
        }

        if (possibleBlueprintItems.length() > 0)
        return possibleBlueprintItems[randi(possibleBlueprintItems.length())];

        return null;
    }

    void GiveRandomBlueprintsCfunc(cvar_t@ arg0)
    {
        auto player = GetLocalPlayer();

        for (int i = 0; i < arg0.GetInt(); i++)
            {
                GiveForgeBlueprintImpl(RandomBlueprintPicker(), player, false);
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
                if (item.canAttune)
                {
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
        auto player = GetLocalPlayer();

        player.m_record.itemForgeAttuned.removeRange(0, player.m_record.itemForgeAttuned.length());
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

    void GiveBloodAltarCfunc(cvar_t@ arg0, cvar_t@ arg1)
    {

        auto ply = GetLocalPlayer();
        auto reward = BloodAltar::GetReward(arg0.GetString());
            if (reward is null)
                {
                    print("you did it wrong");
                    return;
                }

        for (int i = 0; i < arg1.GetInt(); i++)
            {
                ply.m_record.bloodAltarRewards.insertLast(reward.idHash);
            }

    }
}