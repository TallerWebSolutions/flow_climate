import { useContext, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { MeContext } from "../../contexts/MeContext";
import ProjectsList from "../../modules/project/components/ProjectsList";
import {  trackPageView } from "../../amplitude/amplitudeEvents";

const ProjectsPage = () => {
  const { t } = useTranslation(["projects"]);
  const { me } = useContext(MeContext);
  const companyUrl = `/companies/${me?.currentCompany?.slug}`;
  
  
  const breadcrumbsLinks = [
    { name: "Home", url: "/" },
    { name: me?.currentCompany?.name || "", url: companyUrl },
    { name: t("projects") },
  ];

  const amplitudeUser = {
    id: me?.id,
    fullName: me?.fullName,
    companySlug: me?.currentCompany?.slug,
  };

  useEffect(() => {
    if (amplitudeUser?.id)
    return trackPageView("ProjectsPage", amplitudeUser?.id, { user: amplitudeUser },)
  },)
  // eslint-disable-next-line no-console
  console.log(amplitudeUser)

  return (
    <ProjectsList breadcrumbsLinks={breadcrumbsLinks} companyUrl={companyUrl} />
  );
};

export default ProjectsPage;  