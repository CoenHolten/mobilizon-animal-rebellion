<template>
  <form
    id="search-anchor"    
    role="search"
    @submit.prevent="submit"
  >
    <label class="sr-only" for="search_field_input">{{
      t("Keyword, event title, group name, etc.")
    }}</label>    
    <section class="container mx-auto px-2 my-3">
      <br>
      <b>
      {{t("Search for events or groups")}}
      </b><br>
      {{t("If you don't know what to search for, just press 'Search!'")}}
      <br>
      <br>
    <div  class= "flex flex-wrap flex-col sm:flex-row items-stretch gap-2 text-center items-center justify-center dark:text-slate-100">
    <o-input
      v-model="search"
      :placeholder="t('Keyword, event title, group name, etc.')"
      id="search_field_input"
      autofocus
      autocapitalize="off"
      autocomplete="off"
      autocorrect="off"
      maxlength="1024"
      expanded
    />    
    <full-address-auto-complete
      :resultType="AddressSearchType.ADMINISTRATIVE"
      v-model="location"
      :hide-map="true"
      :hide-selected="true"
      :default-text="locationDefaultText"
      labelClass="sr-only"
      :placeholder="t('City, address, location, etc...')"
    />
    <o-button native-type="submit" icon-left="magnify">
      <template v-if="search">{{ t("Search!") }}</template>
      <template v-else>{{ t("Search!") }}</template>
    </o-button>
  </div>
  </section>
  </form>
</template>

<script lang="ts" setup>
import { IAddress } from "@/types/address.model";
import { AddressSearchType } from "@/types/enums";
import { computed, defineAsyncComponent } from "vue";
import { useI18n } from "vue-i18n";
import { useRouter, useRoute } from "vue-router";
import RouteName from "@/router/name";

const FullAddressAutoComplete = defineAsyncComponent(
  () => import("@/components/Event/FullAddressAutoComplete.vue")
);

const props = defineProps<{
  location: IAddress | null;
  locationDefaultText?: string | null;
  search: string;
}>();

const router = useRouter();
const route = useRoute();

const emit = defineEmits<{
  (event: "update:location", location: IAddress | null): void;
  (event: "update:search", newSearch: string): void;
  (event: "submit"): void;
}>();

const location = computed({
  get(): IAddress | null {
    return props.location;
  },
  set(newLocation: IAddress | null) {
    emit("update:location", newLocation);
  },
});

const search = computed({
  get(): string {
    return props.search;
  },
  set(newSearch: string) {
    emit("update:search", newSearch);
  },
});

const submit = () => {
  emit("submit");
  const lat = location.value?.geom
    ? parseFloat(location.value?.geom?.split(";")?.[1])
    : undefined;
  const lon = location.value?.geom
    ? parseFloat(location.value?.geom?.split(";")?.[0])
    : undefined;
  router.push({
    name: RouteName.SEARCH,
    query: {
      ...route.query,
      locationName: location.value?.locality ?? location.value?.region,
      lat,
      lon,
      search: search.value,
    },
  });
};

const { t } = useI18n({ useScope: "global" });
</script>
<style scoped>
#search-anchor :deep(.o-input__wrapper) {
  flex: 1;
}
</style>
