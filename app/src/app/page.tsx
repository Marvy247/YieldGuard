import Navigation from '@/components/layout/Navigation';
import Footer from '@/components/layout/Footer';
import OracleHeroSection from '@/components/oracle/HeroSection';
import LivePriceFeed from '@/components/oracle/LivePriceFeed';
import ArchitectureSection from '@/components/oracle/ArchitectureSection';
import SecuritySection from '@/components/oracle/SecuritySection';
import MetricsSection from '@/components/oracle/MetricsSection';
import ContractsSection from '@/components/oracle/ContractsSection';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <Navigation />
      <main>
        <OracleHeroSection />
        <LivePriceFeed />
        <ArchitectureSection />
        <SecuritySection />
        <MetricsSection />
        <ContractsSection />
      </main>
      <Footer />
    </div>
  );
}
